package main

import (
	"bufio"
	"flag"
	"net/http"
	"net/url"
	"regexp"
	"strconv"
	"time"

	log "github.com/sirupsen/logrus"

	"github.com/prometheus/client_golang/prometheus"
	"github.com/prometheus/client_golang/prometheus/promauto"
	"github.com/prometheus/client_golang/prometheus/promhttp"
)

const version = "0.0.1"

var (
	zyxelHost     = flag.String("zyxel.host", "10.0.0.2", "URL for the web interface of the GS1200-5HP")
	zyxelPassword = flag.String("zyxel.pass", "1234", "Password for the web interface")
	listenAddress = flag.String("web.listen-address", "[::]:9237", "Web listen address")

	successfulScrapes = promauto.NewCounterVec(prometheus.CounterOpts{
		Namespace: "zyxel",
		Name:      "successful_scrapes_count",
		Help:      "Number of successful scrapes",
	}, []string{"subsystem"})
	failedScrapes = promauto.NewCounterVec(prometheus.CounterOpts{
		Namespace: "zyxel",
		Name:      "failed_scrapes_count",
		Help:      "Number of failed scrapes",
	}, []string{"subsystem"})
	poeNumPorts = promauto.NewGauge(prometheus.GaugeOpts{
		Namespace: "zyxel",
		Subsystem: "poe",
		Name:      "ports_count",
		Help:      "Number of PoE enabled ports",
	})
	poeTotalPower = promauto.NewGauge(prometheus.GaugeOpts{
		Namespace: "zyxel",
		Subsystem: "poe",
		Name:      "total_power_watts",
		Help:      "Total supported system PoE power",
	})
	poeMaxLedPower = promauto.NewGauge(prometheus.GaugeOpts{
		Namespace: "zyxel",
		Subsystem: "poe",
		Name:      "max_led_power_watts",
		Help:      "Threshold at which 'max poe power' LED will light up",
	})
	poeTotalRealPower = promauto.NewGauge(prometheus.GaugeOpts{
		Namespace: "zyxel",
		Subsystem: "poe",
		Name:      "total_real_power_watts",
		Help:      "Total used system PoE power",
	})
	poeMaxTemperature = promauto.NewGauge(prometheus.GaugeOpts{
		Namespace: "zyxel",
		Subsystem: "poe",
		Name:      "max_temperature_celsius",
		Help:      "Max allowed temperature",
	})
	poeRealTemperature = promauto.NewGauge(prometheus.GaugeOpts{
		Namespace: "zyxel",
		Subsystem: "poe",
		Name:      "real_temperature_celsius",
		Help:      "Current system temperature",
	})
	poeVMainSetting = promauto.NewGauge(prometheus.GaugeOpts{
		Namespace: "zyxel",
		Subsystem: "poe",
		Name:      "main_setting_volts",
	})
	poeVMainVoltage = promauto.NewGauge(prometheus.GaugeOpts{
		Namespace: "zyxel",
		Subsystem: "poe",
		Name:      "main_voltage_volts",
	})
	poePortVoltage = promauto.NewGauge(prometheus.GaugeOpts{
		Namespace: "zyxel",
		Subsystem: "poe",
		Name:      "port_voltage_volts",
	})
	poePortEnabled = promauto.NewGaugeVec(prometheus.GaugeOpts{
		Namespace: "zyxel",
		Subsystem: "poe",
		Name:      "port_enabled_bool",
		Help:      "1 if PoE is enabled on this port",
	}, []string{"port"})
	portPortPower = promauto.NewGaugeVec(prometheus.GaugeOpts{
		Namespace: "zyxel",
		Subsystem: "poe",
		Name:      "port_power_watts",
		Help:      "Power used on port",
	}, []string{"port"})
)

func main() {
	flag.Parse()

	go func() {
		scrape()

		ticker := time.NewTicker(30 * time.Second)
		for {
			select {
			case <-ticker.C:
				scrape()
			}
		}
	}()

	http.Handle("/metrics", promhttp.Handler())
	http.ListenAndServe(*listenAddress, nil)
}

func scrape() {
	err := login()
	if err != nil {
		log.WithFields(log.Fields{
			"error": err,
		}).Error("Failed to login")
	}

	err = scrapePoE()
}

func login() error {
	resp, err := http.PostForm("http://"+*zyxelHost+"/login.cgi", url.Values{
		"password": {*zyxelPassword},
	})
	if err != nil {
		return err
	}
	defer resp.Body.Close()
	return err
}

func scrapePoE() error {
	client := http.Client{
		Timeout: 2 * time.Second,
	}
	resp, err := client.Get("http://" + *zyxelHost + "/poe_data.js")
	if resp == nil || resp.Body == nil {
		return err
	}
	defer resp.Body.Close()

	portNumRegex := regexp.MustCompile(`port_num\s*=\s*(\d*)`)
	totalPowerRegex := regexp.MustCompile(`total_power\s*=\s*\[(\d*)\]`)
	maxLedPowerRegex := regexp.MustCompile(`max_led_power\s*=\s*(\d*)`)
	totalRealPowerRegex := regexp.MustCompile(`total_real_power\s*=\s*(\d*)`)
	maxTemperatureRegex := regexp.MustCompile(`temperature_max\s*=\s*(\d*)`)
	realTemperatureRegex := regexp.MustCompile(`temperature_real\s*=\s*(\d*)`)
	vMainSettingRegex := regexp.MustCompile(`vmain_setting\s*=\s*(\d*)`)
	vMainVoltageRegex := regexp.MustCompile(`vmain_voltage\s*=\s*(\d*)`)
	vPortVoltage := regexp.MustCompile(`vport_voltage\s*=\s*(\d*)`)
	statsRegex := regexp.MustCompile(`\[(\d+),(\d+)\]`)
	statsCount := 1

	scanner := bufio.NewScanner(resp.Body)
	for scanner.Scan() {
		line := scanner.Text()

		if matches := portNumRegex.FindStringSubmatch(line); matches != nil {
			val, _ := strconv.ParseFloat(matches[1], 64)
			poeNumPorts.Set(val)
		} else if matches := totalPowerRegex.FindStringSubmatch(line); matches != nil {
			val, _ := strconv.ParseFloat(matches[1], 64)
			poeTotalPower.Set(val)
		} else if matches := maxLedPowerRegex.FindStringSubmatch(line); matches != nil {
			val, _ := strconv.ParseFloat(matches[1], 64)
			poeMaxLedPower.Set(val)
		} else if matches := totalRealPowerRegex.FindStringSubmatch(line); matches != nil {
			val, _ := strconv.ParseFloat(matches[1], 64)
			poeTotalRealPower.Set(val)
		} else if matches := maxTemperatureRegex.FindStringSubmatch(line); matches != nil {
			val, _ := strconv.ParseFloat(matches[1], 64)
			poeMaxTemperature.Set(val)
		} else if matches := realTemperatureRegex.FindStringSubmatch(line); matches != nil {
			val, _ := strconv.ParseFloat(matches[1], 64)
			poeRealTemperature.Set(val)
		} else if matches := vMainSettingRegex.FindStringSubmatch(line); matches != nil {
			val, _ := strconv.ParseFloat(matches[1], 64)
			poeVMainSetting.Set(val)
		} else if matches := vMainVoltageRegex.FindStringSubmatch(line); matches != nil {
			val, _ := strconv.ParseFloat(matches[1], 64)
			poeVMainVoltage.Set(val)
		} else if matches := vPortVoltage.FindStringSubmatch(line); matches != nil {
			val, _ := strconv.ParseFloat(matches[1], 64)
			poePortVoltage.Set(val)
		} else if matches := statsRegex.FindStringSubmatch(line); matches != nil {
			port := strconv.Itoa(statsCount)
			enabled, _ := strconv.ParseFloat(matches[1], 64)
			power, _ := strconv.ParseFloat(matches[2], 64)
			poePortEnabled.WithLabelValues(port).Set(enabled)
			portPortPower.WithLabelValues(port).Set(power)
			statsCount += 1
		}
	}

	if statsCount > 1 {
		successfulScrapes.WithLabelValues("poe").Inc()
	} else {
		failedScrapes.WithLabelValues("poe").Inc()
	}
	return nil
}
