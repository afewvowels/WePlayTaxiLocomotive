# 🚕 WePlay: Taxi Train

**A teeny, zippy, electric taxi locomotive for Factorio 2.1.** Half the size of a vanilla locomotive, twice the top speed, and it charges itself from your power poles.

![Taxi Train](thumbnail.png)

📦 **Download on the Factorio mod portal:** [mods.factorio.com/mod/WePlayTaxiLocomotive](https://mods.factorio.com/mod/WePlayTaxiLocomotive)

---

## ✨ Features

* **Half-size:** two taxis fit in one vanilla train car slot, on your normal rails
* **Fast:** 518 km/h top speed, perfect for crossing a megabase
* **Electric:** a 100 MJ battery that charges at 10 MW whenever the taxi is stopped near a powered pole. No coal and no pollution.
* **Elevated rails ready:** tilts up and down rail ramps with 160 sloped frames ⛰️
* **Hand-modeled graphics** rendered in Blender, with shadows 🌑
* **Easy to get:** unlocked by **Railway** research, made from 10 iron plates and 5 iron gear wheels

## ⚡ Stats

| | Taxi Train | Vanilla Locomotive |
|---|---|---|
| Top speed | **518 km/h** | 259 km/h |
| Power | **1 MW, electric** | 600 kW, burner |
| Weight | **300** | 2000 |
| Size | **Half a car slot** | One car slot |
| Battery | **100 MJ**, charges at 10 MW | Burns fuel |

A full battery gives about 100 seconds of full throttle. Put a power pole at your stations and the taxi tops up every time it stops.

## 🚂 Pairs With Choo-Choo Taxi

The Taxi Train makes a great personal shuttle train with **[WePlay: Choo-Choo Taxi](https://mods.factorio.com/mod/WePlayChooChooTaxi)**: call it from the shortcut bar, pick a station, and it heads back to its depot (and recharges there) when you hop out.

## 📥 Installing

Install it from the in-game mod manager (search for **WePlay: Taxi Train**) or download it from the [mod portal](https://mods.factorio.com/mod/WePlayTaxiLocomotive).

**Requires:** Factorio 2.1 (base game). Space Age and Elevated Rails are optional.

## 🛠️ How It Works

Factorio doesn't let locomotives connect to the power grid, so the taxi's burner acts as its battery. It only accepts a hidden 100 MJ charge item that `control.lua` fills while the taxi is stopped. An invisible `wp-taxi-charger` (an electric energy interface) sits under the stopped taxi and draws from whatever pole network covers that spot, so the power shows up in your electric network stats as "Taxi charger".

This repo is the mod folder itself: `info.json` is at the root. Release zips are named `WePlayTaxiLocomotive_<version>.zip` and leave out this README and the LICENSE.

## 💖 Credits

Inspired by the classic **Real Shuttle Train** mod and its little electric shuttle locomotive.

Made by **afewvowels**. More WePlay mods: [mods.factorio.com/user/afewvowels](https://mods.factorio.com/user/afewvowels)

## 📄 License

Released under [the Unlicense](LICENSE) (public domain). Use it however you like!
