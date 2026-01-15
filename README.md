## ICT4Geomatics

# ICT - Lab 1: Raw GNSS Measurements from Android Smartphones

This lab focuses on accessing, analyzing, and processing raw GNSS measurements from Android devices, opening the door to advanced GNSS processing techniques beyond standard location APIs.

## Background and Motivation

### GNSS in Consumer Devices Evolution
- **1999**: First GPS-enabled phone (Benefon Esc)
- **2000**: Selective Availability (SA) switched off
- **2004-2005**: Consumer GPS devices (TomTom, Garmin) and Google Maps
- **2016**: Google enabled access to raw GNSS measurements (Android API Level 24)
- **2018**: First dual-frequency smartphone (Xiaomi Mi 8 Pro with Broadcom BCM47755)
- **2020**: Second generation chipsets (BCM47765) with HD-GPS and optional on-chip PVT

### Benefits of Raw Measurements Access
- **Cost-effective precise positioning**: Using Commercial Off-The-Shelf (COTS) devices
- **Multi-constellation support**: GPS, GLONASS, BeiDou, Galileo, QZSS, SBAS
- **Multi-frequency capability**: L1, L5 (and L2 in newer chipsets)
- **Advanced processing**: Access to code and carrier phase measurements
- **Sensor fusion**: Integration with IMU and other embedded sensors
- **Flexibility**: Optimize multi-GNSS solutions, optional on-chip PVT

## GNSS Architecture in Android Devices

### Hardware
- **Broadcom BCM47755/BCM47765 chipsets**: Integrated multi-frequency GNSS baseband and RF front-end
- **Supported systems**: GPS, GLONASS, BeiDou, Galileo, SBAS
- **Features**: Position batching, geofencing, sensor fusion, sensor navigation

### Software Stack
- **Location APIs**: Places, Geofencing, Fused Location Provider (FLP)
- **Activity APIs**: Fit, Activity Recognition, Nearby
- **Measurement APIs**: Location, GNSS Measurement, GNSS Clock
- **Raw GNSS Measurements access**: Through GnssMeasurement API

## Raw GNSS Measurement Parameters

### Essential Fields for Pseudorange Calculation

#### Time Information
- **getTimeNanos()**: Local timestamp attributed to measurements (may have discontinuities)
- **getFullBiasNanos()**: Full bias in nanoseconds (includes leap seconds)
- **getBiasNanos()**: Sub-nanosecond bias
- **ReceivedSvTimeNanos**: Satellite transmission time in GNSS time scale

#### Pseudorange Computation
**Reception Time (GNSS time scale)**:
```
RxTime = getTimeNanos() - (getFullBiasNanos() + getBiasNanos()) - weekNumberNanos
```

**Transmission Time**:
```
TxTime = ReceivedSvTimeNanos
```

**Pseudorange Measurement**:
```
ρ_raw = (RxTime - TxTime) × c
```
Where c is the speed of light (~299,792,458 m/s)

### Signal Quality Parameters
- **Cn0DbHz**: Carrier-to-Noise density ratio (signal strength indicator)
- **State flags**: Lock status, cycle slip detection
- **AccumulatedDeltaRange**: Carrier phase measurements (for high-precision applications)

### Satellite Information
- **Svid**: Satellite vehicle ID
- **ConstellationType**: GPS, GLONASS, BeiDou, Galileo, etc.
- **AzimuthDegrees**: Satellite azimuth angle
- **ElevationDegrees**: Satellite elevation angle

## Tools and Software

### GNSS Logger App (Google)
- **Download**: Available from GitHub (google/gps-measurement-tools)
- **Features**:
  - Log raw GNSS measurements
  - Real-time skyplot visualization
  - C/N₀ signal strength plots
  - Multiple location provider comparison (GNSS, Network, Fused)
  - Timed logging for consistent data collection
  
### GNSS Analysis MATLAB Tool
- **Download**: From Google's gps-measurement-tools repository
- **Capabilities**:
  - Process raw measurements from Android devices
  - Compute pseudoranges and pseudorange rates
  - Automatic ephemeris download from NASA CCDIS
  - Satellite visibility analysis
  - Signal quality assessment (C/N₀ tracking)
  - Data filtering options (constellation, signal strength, satellite ID)
  - PVT solution computation (Lab 2)

## Data Analysis Workflow

### 1. Data Collection
- Use GNSS Logger app on Android device (API Level 24+)
- Collect measurements for 10+ minutes
- Record location details and environmental conditions
- Note potential obstacles and visibility constraints

### 2. Data Processing with MATLAB
**Main Script**: `ProcessGnssMeasScript.m`

**Key Functions**:
- `ProcessGnssMeas(gnssRaw)`: Process raw measurements, compute pseudoranges
- `SetDataFilter()`: Configure measurement filters
- Automatic ephemeris retrieval and extraction

**Output Structure** (`gnssMeas`):
- `FctSeconds`: Fetch time (local time)
- `tRxSeconds`: Reception time (GPS week seconds)
- `tTxSeconds`: Transmission time (GPS week seconds)
- `PrM`: Pseudorange measurements [m]
- `PrSigmaM`: Pseudorange standard deviation [m]
- `DelPrM`: Delta pseudorange measurements [m]
- `PrrMps`: Pseudorange rate [m/s]
- `Cn0DbHz`: Carrier-to-noise density ratio [dB-Hz]
- `Svid`: Satellite IDs
- `AzDeg`, `ElDeg`: Azimuth and elevation angles [degrees]

### 3. Data Quality Assessment
- **C/N₀ analysis**: Identify strongest and weakest signals
- **Pseudorange continuity**: Detect jumps or discontinuities
- **Satellite visibility**: Track number of visible satellites over time
- **DOP analysis**: Assess geometric dilution of precision

## Lab Tasks

### Task 1: Initial Testing
Download Google's GPS measurement tools and run demo datasets. Familiarize with the MATLAB code structure and output.

### Task 2: Data Analysis and Interpretation
- Observe generated figures and measurement behavior over time
- Analyze relationship between satellite distance (pseudorange) and C/N₀ levels
- Understand signal propagation and quality variations
- Study temporal trends of key quantities

### Task 3: Satellite Availability Analysis
- Design routine to count visible satellites per epoch
- Check if multi-lateration conditions are satisfied (minimum 4 satellites for 3D positioning)
- Compute percentage of time with sufficient satellites for PVT estimation
- Assess GNSS service availability for the collected dataset

### Task 4: Data Filtering Investigation
- Apply C/N₀ thresholds to filter weak signals
- Compare results with different constellation combinations:
  - GPS only
  - GPS + GLONASS
  - GPS + Galileo
  - Full multi-constellation (GPS + GLONASS + Galileo + BeiDou)
- Evaluate impact on PVT availability and quality
- Analyze trade-offs between measurement quality and availability

### Task 5: Custom Data Collection
- Collect new datasets (10 minutes) using personal Android device
- Process data with MATLAB analysis tool
- Report satellite availability and compare with demo datasets
- Discuss environmental factors affecting measurements

### Task 6: Skyplot and Signal Correlation
- Compare satellite positions from skyplot with C/N₀ levels
- Identify obstacles affecting signal reception
- Use GNSS planning tools (e.g., https://www.gnssplanning.com) to verify satellite geometry
- Correlate elevation angles with signal strength
- Investigate multipath and obstruction effects

### Task 7: Code Exploration
- Access inner levels of MATLAB script
- Identify where essential PVT information is extracted
- Understand data structures for Least Squares implementation
- Prepare for Lab 2 state estimation tasks

## Additional Resources
- **White Paper**: "Using GNSS Raw Measurements on Android Devices" (EU Agency for Space Programme)
- **Device Compatibility**: Check at http://g.co/gnsstools
- **Galileo Support**: Verify at https://www.usegalileo.eu
- **Ephemeris Source**: NASA CCDIS (Crustal Dynamics Data Information System)
- **GNSS Planning Tools**: For satellite visibility prediction

## Expected Outcomes
- Understanding of raw GNSS measurement structure in Android devices
- Ability to collect and process raw measurements
- Skills in data quality assessment and filtering
- Knowledge of factors affecting GNSS performance
- Preparation for implementing positioning algorithms (Lab 2)

# ICT - Lab 2: Receiver State Estimation using Least Squares

This lab focuses on implementing an iterative Least Squares (LS) estimator to compute Position, Velocity, and Time (PVT) solution from raw GNSS pseudorange measurements.

## GNSS Radionavigation Fundamentals

### The Multi-Lateration Problem
GNSS positioning is based on measuring distances (pseudoranges) from multiple satellites to determine the receiver's position and clock bias.

**Observable-State Relationship**:
```
ρⱼ = ||pⱼ - p|| - bᵤ
```
Where:
- ρⱼ: Measured pseudorange to satellite j
- pⱼ: Known satellite position [xⱼ, yⱼ, zⱼ]
- p: Unknown receiver position [x, y, z]
- bᵤ: Unknown receiver clock bias

**State Vector**: x = [x, y, z, bᵤ]ᵀ (4 unknowns)
**Minimum Requirements**: At least 4 satellites for 3D position + clock bias

### Why Least Squares?
- **Non-linear system**: Direct algebraic solution not possible
- **Overdetermined system**: More measurements than unknowns (typically)
- **Optimal estimation**: LS minimizes squared residuals between observed and predicted measurements
- **Iterative refinement**: Converges to solution through linearization

## Least Squares Method

### Residuals and Optimization
**Residuals**: Δρ = ρ - ρ̂

Where:
- ρ: Observed (measured) pseudoranges
- ρ̂: Nominal (predicted) pseudoranges from current position estimate

**Objective**: Minimize ||Δρ||² (squared norm of residuals)

### Linearization
Since pseudorange equations are non-linear, we linearize around a trial solution:

**LS Solution**:
```
Δx = (HᵀH)⁻¹Hᵀ Δρ
```

Where:
- H: Geometry matrix (design matrix)
- Δx: Correction to current position estimate
- Δρ: Measurement residuals

## Iterative Least Squares Algorithm

### Algorithm Structure

**For each epoch n** (new set of measurements):

1. **Initialization**: Set initial linearization point x̂ₙ⁰
   - Option 1: Fixed initial point (e.g., Earth center or approximate location)
   - Option 2: Previous epoch solution (warm start)

2. **Iterate for k = 1, 2, ..., K** (typically K = 8 iterations):

   a. **Compute nominal pseudoranges** from current estimate:
   ```
   ρ̂ⱼ,ₙᵏ = ||pⱼ,ₙ - p̂ₙᵏ|| - c·δtⱼ,ₙ - b̂ᵤ,ₙᵏ
   ```
   Where:
   - c·δtⱼ,ₙ: Satellite clock correction (from ephemeris)
   
   b. **Compute residuals**:
   ```
   Δρₙᵏ = ρₙ - ρ̂ₙᵏ
   ```
   
   c. **Build geometry matrix** H:
   ```
   H[j,:] = [aₓⱼ, aᵧⱼ, aᵤⱼ, 1]
   ```
   Where:
   ```
   aₓⱼ = (xⱼ - x̂)/rⱼ
   aᵧⱼ = (yⱼ - ŷ)/rⱼ
   aᵤⱼ = (zⱼ - ẑ)/rⱼ
   rⱼ = ||pⱼ - p̂||  (geometric range)
   ```
   
   d. **Compute LS correction**:
   ```
   Δxₙᵏ = (Hₙᵏᵀ Hₙᵏ)⁻¹ Hₙᵏᵀ Δρₙᵏ
   ```
   
   e. **Update solution**:
   ```
   x̂ₙᵏ⁺¹ = x̂ₙᵏ - Δxₙᵏ
   ```

3. **Output**: Final estimate x̂ₙᴷ for epoch n

### Convergence
- Solution converges when ||Δxₙᵏ|| becomes small (typically < 0.01 m)
- Each iteration brings the estimate closer to the true position
- Convergence typically achieved in 5-8 iterations
- Poor initialization may require more iterations

## Geometry Matrix Details

### Structure
For J visible satellites at epoch n, iteration k:

```
     [aₓ₁  aᵧ₁  aᵤ₁  1]
     [aₓ₂  aᵧ₂  aᵤ₂  1]
Hₙᵏ = [aₓ₃  aᵧ₃  aᵤ₃  1]
     [ ⋮    ⋮    ⋮   ⋮]
     [aₓⱼ  aᵧⱼ  aᵤⱼ  1]
```

Dimensions: J × 4 (J satellites, 4 unknowns)

### Physical Interpretation
- First three columns: Unit vectors from receiver to satellites (line-of-sight)
- Fourth column: Clock bias coefficient (all ones)
- Matrix rank depends on satellite geometry (related to DOP)

## Variable Satellite Visibility

### Dynamic Constellation
- Number of visible satellites J varies over time
- Satellites rise and set based on orbit geometry
- Obstructions affect visibility
- H matrix dimensions change: J×4 (variable J, fixed 4)

### Requirements
- **Minimum**: J ≥ 4 for unique 3D solution
- **Optimal**: J > 4 for overdetermined system (redundancy)
- **Quality**: Depends on geometry (GDOP, PDOP, HDOP)

## Implementation in MATLAB

### Core Script: `pvtCore`
Key variables and structure:

**Input from Lab 1**:
- `gnssMeas.PrM`: Pseudorange measurements [N×M matrix]
  - N: Number of epochs
  - M: Maximum number of satellites
- `gnssMeas.tRxSeconds`: Reception times
- `gnssMeas.tTxSeconds`: Transmission times
- `allGpsEph`: GPS ephemeris data

**Iterative Structure** (already provided):
```matlab
for n = 1:N_epochs
    % Initialize for epoch n
    x_hat = initial_position;
    
    for k = 1:K_iterations
        % Compute nominal pseudoranges
        % Build geometry matrix H
        % Compute residuals
        % Apply LS correction
        % Update estimate
    end
    
    % Store final solution for epoch n
end
```

**Key Functions to Implement**:
1. Nominal pseudorange calculation
2. Geometry matrix construction
3. LS correction computation
4. Position estimate update

### Testing
Uncomment the line calling `GpsWlsPvt` function in main script to test implementation.

## Lab Tasks

### Task A: State Estimation Implementation

#### Task A.1: Code Familiarization
- Locate `pvtCore` script in MATLAB code from Lab 1
- Study variable definitions and data structures
- Understand calling functions and data flow
- Review prepared iterative structure

#### Task A.2: Implement LS Algorithm
Implement the core PVT estimation block:

**Required Steps**:
1. **Compute nominal pseudoranges**:
   - Extract satellite positions from ephemeris
   - Calculate geometric range: ||pⱼ - p̂||
   - Apply satellite clock corrections
   - Add receiver clock bias estimate

2. **Build geometry matrix H**:
   - Compute unit vectors from receiver to each satellite
   - Construct J×4 matrix with clock bias column

3. **Compute measurement residuals**:
   - Δρ = ρ_measured - ρ_nominal

4. **Apply LS correction**:
   - Compute (HᵀH)⁻¹
   - Calculate Δx = (HᵀH)⁻¹Hᵀ Δρ

5. **Update position estimate**:
   - x̂_new = x̂_old - Δx

**Hints**:
- Iterative structure already prepared
- Some variables pre-defined
- Explore script to identify missing quantities
- Use MATLAB matrix operations efficiently

#### Task A.3: Validation
- Uncomment `GpsWlsPvt` function call in main script
- Test with demo datasets
- Verify convergence behavior
- Check position accuracy against known coordinates

### Task B: Custom Dataset Analysis

#### Task B.1: Static Dataset Processing
- Use one of the static datasets collected in Lab 1
- Apply LS estimator to compute position time series
- Analyze results:
  - **Position scatter**: Should cluster around true position
  - **Convergence**: Monitor iteration behavior
  - **Accuracy**: Compare with reference coordinates
  - **Consistency**: Check position stability over time

**Performance Metrics**:
- Mean position error (horizontal and vertical)
- Standard deviation (precision indicator)
- 2D/3D RMS error
- Maximum error

#### Task B.2: Impact of Data Filters
Apply different filters and compare performance:

**Filtering Options**:
1. **C/N₀ threshold**: Remove measurements below certain signal strength
   - Try: 20 dB-Hz, 25 dB-Hz, 30 dB-Hz
   
2. **Constellation selection**:
   - GPS only
   - GPS + GLONASS
   - GPS + Galileo
   - Multi-constellation (all available)

3. **Elevation mask**: Filter satellites below certain elevation angle
   - Common values: 5°, 10°, 15°

**Analysis Questions**:
- Did performance improve or degrade? Why?
- Trade-off between measurement quality and quantity
- Impact on solution availability
- Effect on position accuracy and precision
- Convergence speed differences

#### Task B.3: Comparative Analysis
**Requirements for Final Report**:
- Process at least 2 datasets with different visibility conditions:
  - **Open sky**: Minimal obstructions
  - **Urban canyon**: Buildings, obstacles
  - **Indoor/outdoor transition**
  
- Generate comprehensive plots:
  - Position scatter (2D and 3D)
  - Error time series (East, North, Up)
  - Number of satellites vs. time
  - HDOP/VDOP vs. time
  - C/N₀ distribution
  
- Comment on specific characteristics:
  - Multipath effects
  - Satellite geometry impact
  - Signal quality variations
  - Environmental influences

## Expected Outcomes
- Functional LS-based PVT estimator
- Understanding of iterative positioning algorithms
- Ability to assess positioning performance
- Knowledge of data quality impact on solutions
- Skills in comparative analysis and reporting
- Foundation for advanced filtering techniques (Kalman Filter)

# GEOMATICS - Lab1: Planning of GNSS Survey

This lab focuses on the planning phase for GNSS surveys, which is essential for obtaining precise positioning. The main activities include:

## Key Concepts
- **On-the-field investigation**: Analyzing site conditions including intervisibility, obstacles, electromagnetic interference, and stable structures
- **Satellite configuration analysis**: Evaluating satellite geometry and availability
- **Instrument selection**: Choosing appropriate GNSS receivers and supports for point materialization
- **Observation window selection**: Determining optimal measurement times
- **Baseline definition**: Planning the number and type of baselines

## Planning Tools and Parameters
- **Elevation mask (cut-off angle)**: Used for tropospheric delay reduction
- **DOP (Dilution of Precision)**: Includes GDOP, PDOP, HDOP, VDOP as quality indicators
- **Session length**: Can range from 5 minutes to 24 hours depending on requirements
- **Sampling rate**: From 1 second to 30 seconds or more

## Visualization Tools
- **Visibility plots**: Show satellite availability over time
- **Skyplots**: Display satellite positions in the sky relative to observer
- **Elevation plots**: Show satellite elevation angles
- **DOP analysis**: Assessment of geometric configuration quality

## Exercises
1. **Planning and comparison**: Conduct GNSS planning in four different cities (student's home town, Turin, Sydney, Helsinki) comparing GPS only, GPS+GLONASS, and full GNSS constellation
2. **Calculate elevation and azimuth**: Transform satellite ECEF coordinates to local coordinate system (e,n,u) and compute azimuth and elevation angles
3. **DOP estimation**: Calculate dilution of precision matrices and quality indicators from satellite positions

# GEOMATICS - Lab2: GNSS Data Acquisition Techniques

This lab covers different methods for GNSS data acquisition and field survey strategies.

## Data Acquisition Strategies

### Absolute Positioning (Stand-alone)
- Pseudo-range observations (code-based)
- Absolute precision: 5-10m (95%)
- Suitable for navigation applications

### Differential Positioning (DGPS/RTK)
- Corrections calculated at a base station with known position
- Corrections transmitted in real-time via radio, GSM, or Internet using RTCM protocol
- Precision levels:
  - Code-based: > meter (up to few hundred km)
  - Phase smoothing: < meter (up to few hundred km)
  - Phase-based: Centimeter (10-20 km)

## Relative Positioning Methods

### Static Positioning
- Measurement time: >30 minutes to several hours depending on baseline length
- Baselines: 10 km to >100 km
- Precision: 10⁻⁶ to 10⁻⁸
- Double frequency recommended for baselines > 20 km

### Rapid-Static Positioning
- Measurement time: 20-30 min (L1) or 6-8 min (L1+L2)
- Baselines: <10-15 km
- Precision: 10⁻⁶
- Requires good satellite configuration

### Stop-and-Go (Kinematic)
- Measurement time: <1 min per point (at least two epochs)
- Baselines: A few km
- Precision: Centimeter
- Requires continuous satellite contact
- Initialization time: up to 30 min (L1), 5-6 min (L1+L2), or On-The-Fly (L1+L2)

### Continuous Kinematic
- Continuous measurement while moving
- Rate: 1-5 sec (up to 20 Hz for high-frequency applications)
- Baselines: A few km
- Precision: Centimeter

## GNSS Equipment Types

### Mass Market or Code Only
- Acquire only C/A component
- >6 channels (usually >24)
- Accuracy: 5-10m stand-alone, 1-3m DGPS
- Cost: 50-300€

### Single Frequency (L1 only)
- Acquire C/A and L1
- >12 channels
- Can store raw data
- Accuracy: mm-cm (short baselines)
- Cost: 500-5000€

### Multi-Frequency P-code/Y-code
- Acquires all signal components (L1, L2, C/A, P, L5, etc.)
- Multi-constellation support (GPS, GLONASS, Galileo)
- Accuracy: 2-20 cm in RTK
- Cost: >6000€

## GNSS Data Formats
- **Proprietary binary formats**: Manufacturer-specific
- **RINEX**: Independent Receiver Exchange format (.OBS, .NAV)
- **NMEA**: Real-time coordinates via serial port
- **RTCM**: Real-time differential corrections

## RTK and NRTK Positioning

### RTK (Real-Time Kinematic)
- Master-Rover configuration
- Real-time solution with known master coordinates
- Measurement time: 5-10 seconds
- Baselines: <20 km
- High productivity

### NRTK (Network RTK)
- Uses permanent CORS (Continuously Operating Reference Stations) network
- GSM/GPRS connection required
- Real-time RTCM corrections from network
- Measurement time: 5-10 seconds
- Example: SPIN GNSS Service (Italy)

## Static Network Surveys
- Multiple receivers collecting data simultaneously
- Post-processing with double difference method
- High precision (mm level)
- Used for geodetic networks, deformation monitoring, structural monitoring
- N receivers → N-1 independent baselines
- Redundancy factor R for quality control

## Exercises
1. **NRTK survey simulation**: Practice with receiver interface and data collection procedures
2. **Network planning**: Calculate number of sessions needed based on redundancy requirements

# GEOMATICS - Lab3: Geodesy and Reference Systems

This lab covers coordinate transformations, ellipsoid parameters, and datum transformations.

## Ellipsoid Parameters
Study of various reference ellipsoids:
- Bessel (1841): a = 6,377,397 m, f = 1/299.2
- Clarke (1880): a = 6,378,243 m, f = 1/293.5
- Hayford (1909): a = 6,378,388 m, f = 1/297.0
- WGS84 (1984): a = 6,378,137 m, f = 1/298.257223563

## Coordinate Transformations

### Geographic to Geocentric (φ,λ,h) → (X,Y,Z)
Parametric equations of the ellipsoid:
- X = (a/W + h) · cos φ · cos λ
- Y = (a/W + h) · cos φ · sin λ
- Z = (a(1-e²)/W + h) · sin φ

Where W = √(1 - e² · sin²φ)

### Geocentric to Geographic (X,Y,Z) → (φ,λ,h)
Iterative procedure:
1. Calculate longitude: λ = arctan(Y/X)
2. Initial latitude approximation
3. Iterative refinement of latitude and height until convergence (precision: 10⁻⁸)

## Reference System Transformations
- ETRF89 ↔ ITRF89
- ETRF2000 ↔ ITRF2000

## Helmert Transformation
Seven-parameter similarity transformation between datums:
- 3 translations (Tx, Ty, Tz)
- 3 rotations (Rx, Ry, Rz)
- 1 scale factor (λ)

Solved using least squares adjustment with minimum 3 common points.

## Exercises
1. **Ellipsoid parameters**: Calculate and compare parameters (c, e², e'²) for different ellipsoids
2. **Geographic to geocentric transformation**: Convert coordinates using WGS84 and Hayford ellipsoids, analyze the effect of height changes
3. **Geocentric to geographic transformation**: Implement iterative algorithm, analyze convergence and number of iterations
4. **Reference system transformation**: Transform between ETRF and ITRF systems
5. **Helmert transformation**: Estimate 7 parameters using least squares, analyze residuals

# GEOMATICS - Lab4: Cartography and Satellite Imagery

This lab focuses on map projections, coordinate transformations, and satellite image analysis.

## Map Projection Analysis

### Linear Deformation Modulus
Study of UTM projection deformation:
- ml = 0.9996 · √(1 + λ'² · cos²φ / 2)
- Analysis at different latitudes (30°, 37°, 45°, 60°)
- Longitude range: 0° to 3° from central meridian

## Hirvonen Equations

### Direct Transformation: Geographic to UTM (φ,λ) → (E,N)
Formulas for converting geographic coordinates to projected coordinates:
- Calculation of radius of polar curvature (Rp)
- Application of projection formulas
- Multiplication by contraction modulus (mc = 0.9996)
- Addition of False Easting/Northing

### Inverse Transformation: UTM to Geographic (E,N) → (φ,λ)
Reverse process to obtain geographic coordinates from projected coordinates.

## Copernicus Satellite Data Analysis

### Data Products
Access to Copernicus Data Space (https://browser.dataspace.copernicus.eu/)

Products analyzed:
- **NDVI** (Normalized Difference Vegetation Index)
- **Air quality indicators** (CO₂, Methane)
- **True color imagery**
- **False color composites**

### Temporal Analysis
- Multi-year comparison (2020 vs 2025)
- Time-lapse creation with at least 6 years of data
- Theme-based analysis (vegetation, urbanization, environmental changes)

## Exercises
1. **Linear deformation analysis**: Plot and compare deformation at different latitudes
2. **Hirvonen direct transformation**: Convert geographic coordinates to UTM for WGS84 (P1 in Zone 32, P2 in Zone 33)
3. **Hirvonen inverse transformation**: Convert UTM coordinates back to geographic
4. **Copernicus image analysis**: 
   - Create Area of Interest (AOI)
   - Download and compare products from different years
   - Create time-lapse animations for environmental monitoring

# GEOMATICS - Lab5: GNSS Data Processing with RTKLIB

This lab introduces RTKLIB software for GNSS data processing and various positioning techniques.

## RTKLIB Overview
Open-source software suite developed by Tokyo University of Marine Science and Technology.

### Supported Features
- **Constellations**: GPS, GLONASS, Galileo, BeiDou, QZSS, SBAS
- **Positioning modes**: Single, DGPS/DGNSS, Kinematic, Static, Moving-Baseline, PPP
- **Data formats**: RINEX 2.x/3.x, RTCM 2.3/3.x, NMEA, SP3, IONEX, ANTEX
- **Receivers**: NovAtel, u-blox, Hemisphere, SkyTraq, JAVAD, Furuno, NVS

### RTKLIB Components
- **RTKconv**: Data format conversion
- **RTKget**: Download ephemeris and products from web servers
- **RTKpost**: Post-processing analysis (main tool)
- **RTKnavi**: Real-time RTK positioning
- **RTKplot**: Visualization of solutions
- **STRSVR**: Data streaming server

## Processing Options

### Ambiguity Resolution Strategies
- **OFF**: No ambiguity fixing (float solution only)
- **Continuous**: Ambiguities estimated and resolved continuously
- **Instantaneous**: Epoch-by-epoch resolution
- **Fix and Hold**: Once fixed, ambiguities held at estimated values
- **PPP-AR**: Precise Point Positioning with ambiguity resolution (experimental)

### Output Formats
- Lat/Lon/Height (geographic)
- X/Y/Z-ECEF (geocentric)
- E/N/U baseline (local)
- NMEA 0183 messages
- Ellipsoidal or orthometric heights (with geoid models: EGM2008, EGM96)

### Input Files
- Observation files (RINEX .obs)
- Navigation files (.nav, .gnav, .hnav)
- Optional precision products:
  - Precise satellite antenna PCVs
  - Differential Code Biases (DCB)
  - Earth Orientation Parameters (EOP)
  - Ocean Tide Loading (OTL BLQ)
  - Ionospheric delay models

## Processing Workflows

### Static Positioning
- Post-processing of stationary data
- Reference station with known coordinates
- Multi-frequency processing for long baselines
- Quality assessment: ratio test, number of satellites, DOP

### Kinematic Positioning
- Moving rover processing
- Continuous tracking required
- Different fixing strategies: Fix&Hold vs Continuous
- Time-synchronized with reference station

## Exercises

### Exercise 1: Static GNSS Processing
**Input data**:
- TORI reference station (ETRF2000)
- Static observation files (.25o format)
- GPS and GLONASS navigation files
- Antenna height: 1.477 m

**Tasks**:
1. Single point positioning (SPP)
2. Relative positioning using TORI as reference (GPS only)
3. Relative positioning with GPS+GLONASS
4. Comparison of solutions (quality indicators, ratio, number of satellites)
5. Validation against official reference coordinates

### Exercise 2: Kinematic GNSS Processing
**Input data**:
- MONDOVI reference station
- Snow groomer kinematic data
- Observation date: 2020/01/20 17:00:00

**Tasks**:
1. Single point positioning of master station
2. Relative static positioning using different constellations
3. Kinematic processing with Fix&Hold strategy
4. Kinematic processing with Continuous strategy
5. Results comparison and quality analysis
6. Satellite visibility and DOP analysis

### Exercise 3: Field Survey
**Comparison of positioning techniques**:
1. GNSS RTK solution (professional receiver)
2. GARMIN solution (consumer-grade receiver)
3. Smartphone GNSS solution (if available)
4. Distance measurements compared with tape measurements (ground truth)

**Objectives**: Assess accuracy differences between different GNSS equipment types and measurement methods

# GEOMATICS - Lab6: GIS and Digital Mapping

This lab introduces Geographic Information Systems (GIS) using QGIS software for spatial data management and analysis.

## QGIS Interface and Configuration

### Project Setup
- Setting project properties
- Defining coordinate reference systems (CRS)
- Configuring visualization options
- Managing layers and symbology

## Data Types and Import

### Raster Data
- Digital Terrain Models (DTM)
- Aerial imagery and orthophotos
- Satellite imagery
- Visualization using single-band or multi-band rendering
- Color ramp classification

### Vector Data
- Points, lines, polygons
- Attribute tables and data queries
- Categorized and graduated symbology
- Building footprints and infrastructure data

### Other Data Sources
- CSV/Delimited text files with coordinates
- GPX tracks from GPS devices
- WMS/WMTS (Web Map Services)
- Online base maps and tile services

## Data Sources
- **BDTRE** (Regional Topographic Database of Piedmont Region) at 1:10,000 scale
- **Orthophotos**: Regional aerial imagery
- **DTM**: Digital Terrain Models

## GIS Analysis Operations

### Raster Analysis
- **Interpolation methods**:
  - IDW (Inverse Distance Weighting)
  - Natural Neighbor (NN)
- **Terrain analysis**:
  - Contour line extraction
  - Slope calculation
  - Aspect (orientation) analysis
- **Raster calculator**: Mathematical operations between rasters

### Vector Operations
- Selection by attributes
- Spatial queries
- Creating new features and geometries
- Editing attribute tables

### Georeferencing
- Manual point collimation
- Coordinate system transformation
- Residual analysis
- Polynomial transformation methods

## Exercises

### Exercise 1: Import Raster Data
- Load DTM (dtm_155120.asc)
- Configure single-band pseudocolor visualization
- Use information tool to query raster values

### Exercise 2: Import Vector Data
- Load building footprints from BDTRE
- Categorized symbology based on building use
- Attribute table exploration

### Exercise 3: Import Tabular Data
- Import CSV with GNSS coordinates
- Create point layer from coordinates

### Exercise 4: Web Map Services
- Connect to WMS server
- Load regional orthophotos (Piedmont AGEA 2018)
- URL: http://opengis.csi.it/mp/regp_agea_2018

### Exercise 5: Georeferencing
- Georeference CASELLE.TIF map
- Collimate at least 4 ground control points
- Select appropriate transformation
- Validate with BDTRE vector overlay

### Exercise 6: Create New Features
- Digitize new vector geometries
- Add attributes to features

### Exercise 7: Point Cloud Selection
- Import elevation points from ORO folder
- Filter points by attribute (elevation < 350 m)
- Export selection for further processing

### Exercise 8: DTM Creation and Comparison
- Generate DTM using IDW interpolation
- Generate DTM using Natural Neighbor
- Calculate difference using raster calculator
- Analyze interpolation differences

### Exercise 9: Terrain Analysis
- Extract contour lines from DTM
- Generate slope map
- Generate aspect map
- Configure appropriate symbology

### Exercise 10: Import GPX
- Load GPS tracks from GPX files
- Visualize trajectories

### Exercise 11: Create Layout
- Design cartographic layout
- Add map elements (scale, north arrow, legend)
- Export final map product

