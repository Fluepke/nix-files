import urllib.request

with urllib.request.urlopen("https://mobile-token.telekom.de/its?followURL=https://kundencenter.telekom.de") as response:
    print(response.headers.get('Location'))

