# Codes for the PhD Dissertation

This repository contains the MATLAB and Python codes used in the PhD dissertation:

**Gréta Lilla Bányai**
*Decoding Cell Migration – The Impact of Analytical Choices on Biological Interpretation*

## Repository structure

### Single-cell migration analysis

#### Simulation.m
MATLAB script implementing the random walk simulation of cell migration, including the complete analysis pipeline described in the dissertation with the statistical analysis.

**Dissertation reference:**
Methods, Section 4.4.

#### Single-cell_experiment.m
MATLAB script containing the complete analysis pipeline for single-cell migration experiments, except for the determination of cell line-specific morphological features, which were extracted using ImageJ.

The script includes:
- noise filtering of semi-automatically tracked data,
- calculation of migration parameters for manually tracked, semi-automatically tracked, and noise-filtered datasets,
- Area Under the Curve (AUC) calculation,
- statistical analyses.

**Dissertation reference:**
Methods, Sections 4.3.1–4.3.2.

---

### Machine learning pipeline for migration assay comparison

#### scratch_ZE_assay_analysis.ipynb
Google Colab notebook for the machine learning analysis of scratch assay and zone-exclusion (Z-E) assay data.

**Dissertation reference:**
Methods, Sections 4.7.1.2 and 4.7.2.

#### single_cell_analysis.ipynb
Google Colab notebook for the machine learning analysis of single-cell migration assay data.

**Dissertation reference:**
Methods, Sections 4.7.1.1 and 4.7.2.

---

## Software

- MATLAB
- Python (Google Colab / Jupyter Notebook)
