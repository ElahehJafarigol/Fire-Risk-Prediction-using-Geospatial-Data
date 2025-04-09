# 🔥 Wildfire Risk Modeling

This repository contains code to automate the download, processing, and integration of diverse geospatial and environmental datasets needed for wildfire risk assessment in California.

---

## 📌 Overview -  Data Collection Pipeline

This script prepares a unified dataset from the following sources:

- **Fire History Data** (Shapefiles from CalFire)
- **Climate & Weather Data** (NASA POWER NetCDF)
- **Vegetation Index** (MODIS NDVI HDF)
- **Elevation & Canopy Height** (GEDI L2A HDF5)
- **Human Infrastructure** (Roads and Urban Areas from Caltrans)

The final product is a geospatially-aware CSV file with all relevant features merged for ML applications.

---

## 📦 Input Data Sources

| Feature Layer      | Source URL                                                                 |
|--------------------|----------------------------------------------------------------------------|
| Fire Perimeters    | [CalFire](https://data.ca.gov/dataset/california-historical-fire-perimeters) |
| Climate Data       | [NASA POWER](https://power.larc.nasa.gov/data-access-viewer/)              |
| NDVI (Vegetation)  | [MODIS NDVI](https://search.earthdata.nasa.gov/search)                     |
| Elevation Data     | [GEDI L2A](https://search.earthdata.nasa.gov/search)                        |
| Roads              | [Caltrans Roads](https://gisdata-caltrans.opendata.arcgis.com)             |
| Urban Areas        | [Caltrans Urban](https://gisdata-caltrans.opendata.arcgis.com)             |

---

## 🌍 Geographic Extent

Bounding box used for clipping all spatial data:
- **Latitude:** 32.76 to 35.17
- **Longitude:** -120.38 to -116.87

Coordinate Reference Systems:
- **EPSG:4326 (WGS84)** for geospatial processing
- **EPSG:3310 (California Albers)** for accurate distance computation

---

## 🛠️ Outputs

All datasets are merged and saved as:

- `Fire_Risk_Data.csv`: Full dataset for wildfire risk modeling
- Intermediate files: NDVI, Climate, Elevation, and Fire data CSVs

---

## 🧪 Dependencies

Install all required packages:

```bash
pip install geopandas xarray pyhdf h5py

🚀 How to Run
This pipeline is designed to be run in Google Colab for ease of data access and scripting. You will need to upload relevant shell scripts and data into your Drive and mount it.

📂 Directory Structure

/Fire
│
├── train_data_collection_and_preparation.py
├── data_loader.py
├── vegetation-filtered-download.sh
├── elevation-download.sh
├── *.shp, *.hdf, *.nc files
└── Fire_Risk_Data.csv

🧾 License
This repository is open source and available under the MIT License.
