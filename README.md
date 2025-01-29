# Vascular Permeability Quantification Macro

## Description
This ImageJ macro quantifies vascular permeability based on 3D image stacks from animals injected with a fluorescent contrast agent. It measures fluorescence intensity in specific regions of interest (ROIs) to calculate the **Relative Vascular Permeability**.

### How It Works:
1. The user selects a Folder that contains the respective Image files
2. the user places number of round, pre-defied ROIs in the space between micro-vessels to measure the **Intravascular intensity** (fluorescent dye leakage).
3. A larger ring-shaped ROI is automatically generated around each selected ROI to measure the **Local intensity** (including vessels).
4. The macro calculates the **Relative Vascular Permeability** as the ratio of Intravascular intensity to Local intensity.

This macro was originally developed for data from a custom-built multiphoton endomicroscope but should also work with similar datasets from other imaging systems.

---

## Features
- Automatically processes all Bioformats-compatible image files in a selected folder.
- Calculates and exports:
  - **Intravascular intensity**
  - **Local intensity**
  - **Relative Vascular Permeability**
- Saves results in a CSV file for easy analysis.

---

## Requirements
- **Software**: [ImageJ](https://imagej.nih.gov/ij/) or [Fiji](https://fiji.sc/) with the Bioformats plugin installed.
- **Input data**: Hyperstack images in Bioformats format with a stack order of `XYCZT`.

---

## Installation
1. Download the macro file `VascularPermeability_v2-1.ijm`.
2. Open ImageJ/Fiji.
3. Go to `Plugins > Macros > Install...` and select the downloaded `.ijm` file.
4. The macro will now appear under `Plugins > Macros`.

---

## Usage
1. Open ImageJ/Fiji.
2. Run the macro via `Plugins > Macros > VascularPermeability_v2-1`.
3. Follow the prompts:
   - Select a directory containing your image data (Bioformats-compatible files).
   - Specify parameters (see below).
4. Manually place circular ROIs as prompted by the macro.
5. The macro will iterate through all images in the selected folder and save results in a CSV file named `QuantificationResults.csv`.

---

## Parameters
The macro requires the following user-defined parameters:
- **r1**: Radius of the inner circle ROI for measuring intravascular space (default value provided).
- **r2**: Radius of the outer ring ROI for measuring local intensity (default value provided).
- **pixel_size**: Pixel size in micrometers (default value provided).
- **axial_spacing**: Spacing between axial planes in micrometers (default value provided).

---

## Output
The macro generates a CSV file named `QuantificationResults.csv`, saved to the same directory as your raw data. The file includes:
- **Intravascular intensity**
- **Local intensity**
- **Relative Vascular Permeability**

---

## Example Workflow
1. Prepare your 3D image stacks in Bioformats format (`XYCZT` stack order).
2. Run the macro and select your dataset folder.
3. Define ROIs as prompted by the macro.
4. Review results in `QuantificationResults.csv`.

---

## Troubleshooting
### Common Issues:
- **Bioformats plugin not installed**: Ensure you have Fiji with Bioformats support enabled.
- **Incorrect stack order**: Verify that your images are formatted as `XYCZT`.
- **Parameter errors**: Double-check that you’ve entered valid values for `r1`, `r2`, `pixel_size`, and `axial_spacing`.

---

## Usage
Please cite this GitHub and our manuscript at [DOI]

---

## Contact
For questions, feedback, or bug reports, please contact:
lucas.kreiss90@gmail.com


---

## Acknowledgments
Special thanks to collaborators and contributors who helped develop this macro. This project was inspired by research on in vivo measurements of vascular permeablity conducted using our custom-built multiphoton endomicroscope.
