package main

import (
	"flag"
	"github.com/gin-gonic/gin"
	"github.com/prometheus/client_golang/prometheus"
	"github.com/prometheus/client_golang/prometheus/promhttp"
	"net/http"
	"strconv"
	"time"
)

const namespace = "ios"

var (
	apiSecret     = flag.String("api.secret", "geheim", "API Secret to check for. Send with X-API-SECRET header")
	subPath       = flag.String("web.subPath", "/ios-exporter", "Sub directory to serve from")
	listenAddress = flag.String("web.listenAddress", "[::1]:9474", "Bind to")

	appOpenTime     = map[string]time.Time{}
	iPhoneAppEvents = prometheus.NewGaugeVec(
		prometheus.GaugeOpts{
			Namespace: namespace,
			Name:      "app_events_count",
		}, []string{"device_name", "app_name", "state"})
	iPhoneAppDuration = prometheus.NewHistogramVec(
		prometheus.HistogramOpts{
			Namespace: namespace,
			Name:      "app_open_duration_seconds",
			Buckets:   prometheus.ExponentialBuckets(1, 2, 10),
		}, []string{"device_name", "app_name"})

	iPhoneCharging = prometheus.NewGaugeVec(
		prometheus.GaugeOpts{
			Namespace: namespace,
			Name:      "battery_charging",
			Help:      "1 if the battery is charging",
		}, []string{"device_name"})
	iPhoneBatteryLevel = prometheus.NewGaugeVec(
		prometheus.GaugeOpts{
			Namespace: namespace,
			Name:      "battery_level_percent",
			Help:      "Battery level",
		}, []string{"device_name"})
	iPhoneScreenWidth = prometheus.NewGaugeVec(
		prometheus.GaugeOpts{
			Namespace: namespace,
			Name:      "screen_width_pixels",
			Help:      "Screen width in pixels",
		}, []string{"device_name"})
	iPhoneScreenHeight = prometheus.NewGaugeVec(
		prometheus.GaugeOpts{
			Namespace: namespace,
			Name:      "screen_height_pixels",
			Help:      "Screen height in pixels",
		}, []string{"device_name"})
	iPhoneDeviceInfo = prometheus.NewGaugeVec(
		prometheus.GaugeOpts{
			Namespace: namespace,
			Name:      "device_info",
			Help:      "Various device information exported as labels",
		}, []string{"device_name", "device_is_watch", "device_model", "system_version"})
	iPhoneBrightness = prometheus.NewGaugeVec(
		prometheus.GaugeOpts{
			Namespace: namespace,
			Name:      "brightness_percent",
		}, []string{"device_name"})
	iPhoneVolume = prometheus.NewGaugeVec(
		prometheus.GaugeOpts{
			Namespace: namespace,
			Name:      "volume_percent",
		}, []string{"device_name"})
	iPhoneWlan = prometheus.NewGaugeVec(
		prometheus.GaugeOpts{
			Namespace: namespace,
			Name:      "wlan_info",
		}, []string{"device_name", "wlan_name", "wlan_bssid"})
	iPhoneCellular = prometheus.NewGaugeVec(
		prometheus.GaugeOpts{
			Namespace: namespace,
			Name:      "cellular_info",
		}, []string{"device_name", "cellular_provider", "cellular_technology", "cellular_country"})
	iPhoneUpdates = prometheus.NewCounterVec(
		prometheus.CounterOpts{
			Namespace: namespace,
			Name:      "updates_count",
			Help:      "Messages received from iPhone",
		}, []string{"device_name"})
)

func CheckApiSecret() gin.HandlerFunc {
	return func(c *gin.Context) {
		type authHeader struct {
			Secret string `header:"X-API-SECRET"`
		}
		header := authHeader{}
		if err := c.ShouldBindHeader(&header); err != nil {
			c.AbortWithStatusJSON(http.StatusBadRequest, err)
		}
		if header.Secret != *apiSecret {
			c.AbortWithStatus(http.StatusUnauthorized)
			return
		}
		c.Next()
	}
}

func main() {
	flag.Parse()
	r := gin.New()
	router := r.Group(*subPath)

	router.Use(gin.Logger())
	router.Use(gin.Recovery())
	reportRouter := router.Group("/report")
	reportRouter.Use(CheckApiSecret())

	prometheus.MustRegister(iPhoneAppEvents)
	prometheus.MustRegister(iPhoneAppDuration)

	prometheus.MustRegister(iPhoneUpdates)
	prometheus.MustRegister(iPhoneCharging)
	prometheus.MustRegister(iPhoneBatteryLevel)
	prometheus.MustRegister(iPhoneScreenWidth)
	prometheus.MustRegister(iPhoneScreenHeight)
	prometheus.MustRegister(iPhoneDeviceInfo)
	prometheus.MustRegister(iPhoneBrightness)
	prometheus.MustRegister(iPhoneVolume)
	prometheus.MustRegister(iPhoneWlan)
	prometheus.MustRegister(iPhoneCellular)

	router.GET("/metrics", func(c *gin.Context) {
		h := promhttp.Handler()
		h.ServeHTTP(c.Writer, c.Request)
	})

	reportRouter.POST("/charging", func(c *gin.Context) {
		type chargingReport struct {
			DeviceName string `json:"deviceName"`
			Charging   bool   `json:"charging"`
		}
		var report chargingReport
		if err := c.ShouldBindJSON(&report); err != nil {
			c.AbortWithStatusJSON(http.StatusBadRequest, err)
			return
		}
		value := float64(0)
		if report.Charging {
			value = 1
		}
		deviceLabels := prometheus.Labels{
			"device_name": report.DeviceName,
		}
		iPhoneCharging.With(deviceLabels).Set(value)
		iPhoneUpdates.With(deviceLabels).Inc()

		c.JSON(http.StatusOK, gin.H{"status": "reported"})
	})

	reportRouter.POST("/app-event", func(c *gin.Context) {
		type eventData struct {
			DeviceName string `json:"deviceName"`
			AppName    string `json:"appName"`
			State      bool   `json:"state"`
		}
		var event eventData
		if err := c.ShouldBindJSON(&event); err != nil {
			c.AbortWithStatusJSON(http.StatusBadRequest, err)
			return
		}
		state := "closed"
		if event.State {
			state = "opened"
			appOpenTime[event.AppName] = time.Now()
		} else {
			startTime, ok := appOpenTime[event.AppName]
			if ok {
				iPhoneAppDuration.With(prometheus.Labels{
					"device_name": event.DeviceName,
					"app_name":    event.AppName,
				}).Observe(time.Since(startTime).Seconds())
			}
		}
		iPhoneUpdates.With(prometheus.Labels{
			"device_name": event.DeviceName,
		}).Inc()
		iPhoneAppEvents.With(prometheus.Labels{
			"device_name": event.DeviceName,
			"app_name":    event.AppName,
			"state":       state,
		}).Inc()

		c.JSON(http.StatusOK, gin.H{"status": "reported"})
	})

	reportRouter.POST("/data", func(c *gin.Context) {
		type reportData struct {
			BatteryLevel       float64 `json:"batteryLevel"`
			DeviceIsWatch      bool    `json:"deviceIsWatch"`
			DeviceName         string  `json:"deviceName"`
			DeviceModel        string  `json:"deviceModel"`
			ScreenWidth        float64 `json:"screenWidth"`
			ScreenHeight       float64 `json:"screenHeight"`
			SystemVersion      string  `json:"systemVersion"`
			CurrentVolume      float64 `json:"currentVolume"`
			CurrentBrightness  float64 `json:"currentBrightness"`
			WlanName           string  `json:"wlanName"`
			WlanBSSID          string  `json:"wlanBSSID"`
			CellularProvider   string  `json:"cellularProvider"`
			CellularTechnology string  `json:"cellularTechnology"`
			CellularCountry    string  `json:"cellularCountry"`
		}
		var report reportData
		if err := c.ShouldBindJSON(&report); err != nil {
			c.AbortWithStatusJSON(http.StatusBadRequest, err)
			return
		}
		deviceLabels := prometheus.Labels{
			"device_name": report.DeviceName,
		}
		iPhoneUpdates.With(deviceLabels).Inc()
		iPhoneBatteryLevel.With(deviceLabels).Set(report.BatteryLevel)
		iPhoneScreenWidth.With(deviceLabels).Set(report.ScreenWidth)
		iPhoneScreenHeight.With(deviceLabels).Set(report.ScreenHeight)

		iPhoneDeviceInfo.Delete(nil)
		iPhoneDeviceInfo.With(prometheus.Labels{
			"device_name":     report.DeviceName,
			"device_is_watch": strconv.FormatBool(report.DeviceIsWatch),
			"device_model":    report.DeviceModel,
			"system_version":  report.SystemVersion,
		}).Set(1)
		iPhoneBrightness.With(deviceLabels).Set(report.CurrentBrightness * 100)
		iPhoneVolume.With(deviceLabels).Set(report.CurrentVolume)
		iPhoneWlan.Delete(nil)
		iPhoneWlan.With(prometheus.Labels{
			"device_name": report.DeviceName,
			"wlan_name":   report.WlanName,
			"wlan_bssid":  report.WlanBSSID,
		}).Set(1)
		iPhoneCellular.Delete(nil)
		iPhoneCellular.With(prometheus.Labels{
			"device_name":         report.DeviceName,
			"cellular_provider":   report.CellularProvider,
			"cellular_technology": report.CellularTechnology,
			"cellular_country":    report.CellularCountry,
		}).Set(1)

		c.JSON(http.StatusOK, gin.H{"status": "reported"})
	})

	http.ListenAndServe(*listenAddress, r)
}
