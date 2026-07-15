namespace RemObjects.Elements.RTL.Units;

type
  Distance = public dimension(Double);
  Area = public dimension(Distance**2);
  Volume = public dimension(Distance**3);

  Nanometers = public unit(Distance) as nm = 0.000000001m;
  Micrometers = public unit(Distance) as µm = 0.000001m;
  Millimeters = public unit(Distance) as mm = 0.001m;
  Centimeters = public unit(Distance) as cm = 0.01m;
  Meters = public unit(Distance) as m;
  Kilometers = public unit(Distance) as km = 1000m;
  Inches = public unit(Distance) as &in = 0.0254m;
  Feet = public unit(Distance) as ft = 0.3048m;
  Yards = public unit(Distance) as yd = 0.9144m;
  Miles = public unit(Distance) as mi = 1609.344m;
  NauticalMiles = public unit(Distance) as nmi = 1852m;
  AstronomicalUnits = public unit(Distance) as au = 149597870700m;
  LightSeconds = public unit(Distance) = 299792458m;
  LightYears = public unit(Distance) as ly = 9460730472580800m;
  Parsecs = public unit(Distance) as pc = 30856775814913673m;

  SquareMeters = public unit(Area) as m² = m**2;
  SquareKilometers = public unit(Area) as km² = km**2;
  Hectares = public unit(Area) as ha = 10000m²;
  Acres = public unit(Area) as acre = 4046.8564224m**2;

  Liters = public unit(Volume) as L = 0.001m**3;
  Centiliters = public unit(Volume) as cL = 0.01L;
  Milliliters = public unit(Volume) as mL = 0.001L;
  CubicMeters = public unit(Volume) as m³ = m**3;
  Gallons = public unit(Volume) as gal = 3.785411784L;
  Quarts = public unit(Volume) as qt = 0.25gal;
  Pints = public unit(Volume) as pt = 0.5qt;

  //
  // Mass
  //

  Mass = public dimension(Double);
  Force = public dimension(Mass*Acceleration);
  Pressure = public dimension(Force/Distance/Distance);
  GravitationalParameter = public dimension(Distance**3/Time**2);

  Milligrams = public unit(Mass) as mg = 0.001g;
  Grams = public unit(Mass) as g;
  Kilograms = public unit(Mass) as kg = 1000g;
  Tons = public unit(Mass) = 1000kg;
  Pounds = public unit(Mass) = 0.45359237kg;
  Ounces = public unit(Mass) as oz = 0.028349523125kg;
  Stones = public unit(Mass) as st = 6.35029318kg;
  Slugs = public unit(Mass) = 14.59390294kg;

  //
  //
  //

  Density = public dimension(Mass/Volume);

  KilogramsPerCubicMeter = public unit(Density) as kgpm³ = kg/m**3;
  GramsPerMilliliter = public unit(Density) as gpmL = g/mL; // E623 Unit conversion pattern g / mL cannot be resolved to known units or dimensions

  //
  // Chemistry
  //

  AmountOfSubstance = public dimension(Double);
  MolarConcentration = public dimension(AmountOfSubstance/Volume);
  CatalyticActivity = public dimension(AmountOfSubstance/Time);

  Moles = public unit(AmountOfSubstance) as mol;
  Millimoles = public unit(AmountOfSubstance) as mmol = 0.001mol;
  Micromoles = public unit(AmountOfSubstance) as µmol = 0.000001mol;
  Molar = public unit(MolarConcentration) as M = mol/m³;
  Millimolar = public unit(MolarConcentration) as mM = 0.001M;
  Micromolar = public unit(MolarConcentration) as µM = 0.000001M;
  Molality = public dimension(AmountOfSubstance/Mass);
  MolarMass = public dimension(Mass/AmountOfSubstance);
  ReactionRate = public dimension(MolarConcentration/Time);

  MolesPerKilogram = public unit(Molality) as molpkg = mol/kg;
  GramsPerMole = public unit(MolarMass) as gpmol = g/mol;
  KilogramsPerMole = public unit(MolarMass) as kgpmol = kg/mol;
  MolesPerCubicMeterSecond = public unit(ReactionRate) as molpm³ps = mol/m³/s;
  MolesPerLiterSecond = public unit(ReactionRate) as molpLps = mol/L/s;
  MolesPerCubicMeter = public unit(MolarConcentration) as molpm³ = mol/m³;
  MilliosmolesPerLiter = public unit(MolarConcentration) as mOsmpL = 0.001mol/L;

  CatalyticActivityConcentration = public dimension(CatalyticActivity/Volume);
  EnzymeUnitsPerLiter = public unit(CatalyticActivityConcentration) as UpL = (0.000000016666666666666667mol/s)/L;
  //Cells = public unit(Information) as cells;
  //CellsPerMilliliter = public unit(Double/Volume) as cellspmL = 1/mL;

  //
  // Time
  //

  Time = public dimension(Double);

  Microseconds = public unit(Time) as µs = 0.000001s;
  Milliseconds = public unit(Time) as ms = 0.001s;
  Seconds = public unit(Time) as s;
  Minutes = public unit(Time) = 60s;
  Hours = public unit(Time) = 60 Minutes;
  Days = public unit(Time) = 24 Hours;
  Weeks = public unit(Time) = 7 Days;
  Fortnights = public unit(Time) = 14 Days;
  Shakes = public unit(Time) = 0.00000001s;

  TimeSquared = public dimension(Time**2);

  SecondsSquared = public unit(TimeSquared) as s² = s**2;
  HoursSquared = public unit(TimeSquared) as h² = h**2;

  //
  // Speed & Co
  //

  Speed = public dimension(Distance/Time);

  MetersPerSecond = public unit(Speed) as mps = m/s;
  KilometersPerHour = public unit(Speed) as kmh = km/Hours; // later "as km/h", MAYBE
  MilesPerHour = public unit(Speed) as mph = mi/Hours;
  Knots = public unit(Speed) as kn = nmi/Hours;
  FeetPerSecond = public unit(Speed) as fps = ft/s;

  Frequency = public dimension(1/Time);
  FlowRate = public dimension(Volume/Time);
  MassFlowRate = public dimension(Mass/Time);
  KinematicViscosity = public dimension(Area/Time);
  PumpingSpeed = public dimension(Volume/Time);

  Hertz = public unit(Frequency) as Hz = 1/s;
  Kilohertz = public unit(Frequency) as kHz = 1000Hz;
  Megahertz = public unit(Frequency) as MHz = 1000000Hz;
  Gigahertz = public unit(Frequency) as GHz = 1000000000Hz;
  Terahertz = public unit(Frequency) as THz = 1000000000000Hz;

  //
  // Forcce & Pressure
  //

  Newton = public unit(Force) as N = kg*m/s**2;
  PoundForce = public unit(Force) as lbf = 4.4482216152605N;
  Pascal = public unit(Pressure) as Pa = N/m**2;
  Bar = public unit(Pressure) = 100000Pa;
  Atmosphere = public unit(Pressure) as atm = 101325Pa;

  Acceleration = public dimension(Speed/Time);
  Momentum = public dimension(Mass*Speed);
  Impulse = public dimension(Force*Time);
  Torque = public dimension(Force*Distance);
  DynamicViscosity = public dimension(Pressure*Time);
  SurfaceTension = public dimension(Force/Distance);
  MomentOfInertia = public dimension(Mass*Distance**2);
  AngularMomentum = public dimension(Torque*Time);
  AngularImpulse = public dimension(Torque*Time);

  MetersPerSecondSquared = public unit(Acceleration) as mps² = m/s/s;
  FeetPerSecondSquared = public unit(Acceleration) as fps² = ft/s/s;

  KilogramMetersPerSecond = public unit(Momentum) as kgmps = kg*m/s;
  NewtonSeconds = public unit(Impulse) as Ns = N*s;
  NewtonMeters = public unit(Torque) as Nm = N*m;
  NewtonsPerMeter = public unit(SurfaceTension) as Npm = N/m;
  KilogramSquareMeters = public unit(MomentOfInertia) as kgm² = kg*m**2;
  KilogramSquareMetersPerSecond = public unit(AngularMomentum) as kgm²ps = kg*m**2/s;
  JouleSecond = public KilogramSquareMetersPerSecond;
  NewtonMeterSeconds = public unit(AngularImpulse) as Nms = N*m*s;
  PascalSeconds = public unit(DynamicViscosity) as Pas = Pa*s;
  Poise = public unit(DynamicViscosity) as P = 0.1Pas;
  Stokes = public unit(KinematicViscosity) as St = cm**2/s;
  KilogramsPerSecond = public unit(MassFlowRate) as kgps = kg/s;

  //
  // Angle
  //

  Angle = public dimension(Double);
  SolidAngle = public dimension(Double);

  Radians = public unit(Angle) as rad;
  Degrees = public unit(Angle) as deg = 0.017453292519943295rad;
  ArcMinutes = public unit(Angle) as arcmin = deg/60;
  ArcSeconds = public unit(Angle) as arcsec = arcmin/60;
  Steradians = public unit(SolidAngle) as sr;

  //
  // Temperature
  //

  Temperature = public dimension(Double);
  HeatCapacity = public dimension(Energy/Temperature);
  SpecificHeatCapacity = public dimension(Energy/(Mass*Temperature));
  ThermalConductivity = public dimension(Power/(Distance*Temperature));
  Entropy = public dimension(Energy/Temperature);
  HeatFlux = public dimension(Power/Area);
  ThermalResistance = public dimension(Temperature/Power);
  ThermalResistivity = public dimension(Distance*Temperature/Power);
  ThermalDiffusivity = public dimension(Area/Time);
  CoefficientOfThermalExpansion = public dimension(1/Temperature);

  Kelvin = public unit(Temperature) as K;
  Celsius = public unit(Temperature) as °C = value + 273.15 K;
  Fahrenheit = public unit(Temperature) as °F = (value + 459.67) * 5 / 9 K;
  Rankine = public unit(Temperature) as °R = value * 5 / 9 K;
  JoulesPerKelvin = public unit(HeatCapacity) as JpK = J/K;
  JoulesPerKilogramKelvin = public unit(SpecificHeatCapacity) as JpkgK = J/(kg*K);
  WattsPerMeterKelvin = public unit(ThermalConductivity) as WpmK = W/(m*K);
  WattsPerSquareMeterHeat = public unit(HeatFlux) as Wpm²h = W/m**2;
  KelvinPerWatt = public unit(ThermalResistance) as KpW = K/W;
  MeterKelvinPerWatt = public unit(ThermalResistivity) as mKpW = m*K/W;
  SquareMetersPerSecond = public unit(ThermalDiffusivity) as m²ps = m**2/s;
  PerKelvin = public unit(CoefficientOfThermalExpansion) as pK = 1/K;

  MassTime = public dimension(Mass*Time);
  MassTimeSquared = public dimension(Mass*Time**2);
  GravitationalConstantDimension = public dimension(Distance**3/(Mass*Time**2));

  GramSeconds = public unit(MassTime) as gs = g*s;
  KilogramSeconds = public unit(MassTime) as kgs = kg*s;
  KilogramSecondsSquared = public unit(MassTimeSquared) as kgs² = kg*s²;
  StandardGravitationalParameter = public unit(GravitationalParameter) as μ = m**3/s**2;
  GravitationalConstantUnits = public unit(GravitationalConstantDimension) = m**3/(kg*s**2);

  //
  // Power & Energy
  //

  Watts = public unit(Power) as W = V*A;
  Milliwatts = public unit(Power) as mW = 0.001W;
  Kilowatts = public unit(Power) as kW = 1000W;
  Horsepower = public unit(Power) as hp = 745.6998715822702W;

  Joules = public unit(Energy) as J = W*s;
  Calories = public unit(Energy) as cal = 4.184J;
  Kilocalories = public unit(Energy) as kcal = 1000cal;
  KilowattHours = public unit(Energy) as kWh = kW*Hours;
  Electronvolts = public unit(Energy) as eV = 0.0000000000000000001602176634J;
  Kiloelectronvolts = public unit(Energy) as keV = 1000 eV;
  Megaelectronvolts = public unit(Energy) as MeV = 1000000 eV;
  Gigaelectronvolts = public unit(Energy) as GeV = 1000000000 eV;
  BTUs = public unit(Energy) as BTU = 1055.05585262J;

  //
  // Electricity
  //

  ElectricalCurrent = public dimension(Double);
  ElectricalCharge = public dimension(ElectricalCurrent*Time);
  Voltage = public dimension(Double);
  Resistance = public dimension(Voltage/ElectricalCurrent);
  Impedance = public dimension(Voltage/ElectricalCurrent);
  Reactance = public dimension(Voltage/ElectricalCurrent);
  Conductance = public dimension(ElectricalCurrent/Voltage);
  Admittance = public dimension(ElectricalCurrent/Voltage);
  Susceptance = public dimension(ElectricalCurrent/Voltage);
  Power = public dimension(Voltage*ElectricalCurrent);
  Energy = public dimension(Power*Time);
  Capacitance = public dimension(ElectricalCharge/Voltage);
  MagneticFlux = public dimension(Voltage*Time);
  MagneticFluxDensity = public dimension(MagneticFlux/Area);
  Inductance = public dimension(MagneticFlux/ElectricalCurrent);
  ElectricFieldStrength = public dimension(Voltage/Distance);
  ChargeDensity = public dimension(ElectricalCharge/Volume);
  CurrentDensity = public dimension(ElectricalCurrent/Area);
  Permittivity = public dimension(Capacitance/Distance);
  Permeability = public dimension(Inductance/Distance);
  Resistivity = public dimension(Resistance*Distance);
  Conductivity = public dimension(Conductance/Distance);

  Amperes = public unit(ElectricalCurrent) as A;
  Milliamperes = public unit(ElectricalCurrent) as mA = 0.001A;
  Microamperes = public unit(ElectricalCurrent) as µA = 0.000001A;
  Coulomb = public unit(ElectricalCharge) as C = A*s;
  Volts = public unit(Voltage) as V;
  Millivolts = public unit(Voltage) as mV = 0.001V;
  Kilovolts = public unit(Voltage) as kV = 1000V;
  Ohm = public unit(Resistance) as Ω = V/A;
  Kiloohm = public unit(Resistance) as kΩ = 1000Ω;
  Megaohm = public unit(Resistance) as MΩ = 1000000Ω;
  ImpedanceOhms = public unit(Impedance) as ZΩ = Ω;
  ReactanceOhms = public unit(Reactance) as XΩ = Ω;
  Siemens = public unit(Conductance) as S = A/V;
  AdmittanceSiemens = public unit(Admittance) as YS = S;
  SusceptanceSiemens = public unit(Susceptance) as BS = S;
  Farads = public unit(Capacitance) as F = C/V;
  Microfarads = public unit(Capacitance) as µF = 0.000001F;
  Webers = public unit(MagneticFlux) as Wb = V*s;
  Teslas = public unit(MagneticFluxDensity) as T = Wb/m²;
  Henrys = public unit(Inductance) as H = Wb/A;
  VoltsPerMeter = public unit(ElectricFieldStrength) as Vpm = V/m;
  CoulombsPerCubicMeter = public unit(ChargeDensity) as Cpm³ = C/m**3;
  AmperesPerSquareMeter = public unit(CurrentDensity) as Apm² = A/m**2;
  FaradsPerMeter = public unit(Permittivity) as Fpm = F/m;
  HenrysPerMeter = public unit(Permeability) as Hpm = H/m;
  OhmMeters = public unit(Resistivity) as Ωm = Ω*m;
  SiemensPerMeter = public unit(Conductivity) as Spm = S/m;

  //
  // Radiation & Medicine
  //

  Radioactivity = public dimension(1/Time);
  Wavenumber = public dimension(1/Distance);
  Becquerel = public unit(Radioactivity) as Bq = 1/s;
  Curies = public unit(Radioactivity) as Ci = 37000000000Bq;

  AbsorbedDose = public dimension(Energy/Mass);
  EquivalentDose = public dimension(Energy/Mass);
  MassConcentration = public dimension(Mass/Volume);
  MassDose = public dimension(Mass/Mass);
  DoseRate = public dimension(Mass/Mass/Time);
  SoundIntensity = public dimension(Power/Area);

  Grays = public unit(AbsorbedDose) as Gy = J/kg;
  Sieverts = public unit(EquivalentDose) as Sv = J/kg;
  InverseMeters = public unit(Wavenumber) as pm = 1/m;
  Barns = public unit(Area) = 0.0000000000000000000000000001m**2;
  UnifiedAtomicMassUnits = public unit(Mass) as u = 0.00000000000000000000000000166053906660kg;
  MilligramsPerMilliliter = public unit(MassConcentration) as mgpmL = mg/mL;
  MilligramsPerLiter = public unit(MassConcentration) as mgpL = mg/L;
  MicrogramsPerMilliliter = public unit(MassConcentration) as µgpmL = 0.001mg/mL;
  MilligramsPerKilogram = public unit(MassDose) as mgpkg = mg/kg;
  MicrogramsPerKilogram = public unit(MassDose) as µgpkg = 0.001mg/kg;
  MilligramsPerKilogramPerDay = public unit(DoseRate) as mgpkgpd = mg/kg/Days;
  MillilitersPerHour = public unit(FlowRate) as mLph = mL/Hours;
  MillilitersPerMinute = public unit(FlowRate) as mLpm = mL/Minutes;
  LitersPerSecond = public unit(PumpingSpeed) as Lps = L/s;
  WattsPerSquareMeter = public unit(SoundIntensity) as Wpm² = W/m**2;
  Katals = public unit(CatalyticActivity) as kat = mol/s;

  //
  // Photometry & Radiometry
  //

  LuminousIntensity = public dimension(Double);
  LuminousFlux = public dimension(LuminousIntensity);
  Illuminance = public dimension(LuminousFlux/Area);
  Luminance = public dimension(LuminousIntensity/Area);
  RadiantIntensity = public dimension(Power/SolidAngle);
  Irradiance = public dimension(Power/Area);
  Radiance = public dimension(Power/(Area*SolidAngle));

  Candelas = public unit(LuminousIntensity) as cd;
  Lumens = public unit(LuminousFlux) as lm = cd;
  Lux = public unit(Illuminance) as lx = lm/m**2;
  Nits = public unit(Luminance) as nt = cd/m**2;
  WattsPerSteradian = public unit(RadiantIntensity) as Wpsr = W/sr;
  IrradianceWattsPerSquareMeter = public unit(Irradiance) as Wpm²i = W/m**2;
  WattsPerSquareMeterSteradian = public unit(Radiance) as Wpm²sr = W/(m**2*sr);

  //
  // Information
  //

  Information = public dimension(Double);
  DataRate = public dimension(Information/Time);

  Bits = public unit(Information) as b;
  Bytes = public unit(Information) as B = 8b; // should err, dupe
  Kilobits = public unit(Information) as kb = 1000 b;
  Megabits = public unit(Information) as Mb = 1000 kb;
  Gigabits = public unit(Information) as Gb = 1000 Mb;
  Kilobytes = public unit(Information) as KB = 1000 B;
  Megabytes = public unit(Information) as MB = 1000 KB;
  Gigabytes = public unit(Information) as GB = 1000 MB;
  Kibibytes = public unit(Information) as KiB = 1024 B;
  Mebibytes = public unit(Information) as MiB = 1024 KiB;
  Gibibytes = public unit(Information) as GiB = 1024 MiB;
  BitsPerSecond = public unit(DataRate) as bps = b/s;
  BytesPerSecond = public unit(DataRate) as Bps = B/s; // should err, dupe

  PoundsPerSquareInch = public unit(Pressure) as psi = 6894.757293168Pa;
  Torr = public unit(Pressure) = 133.3223684211Pa;
  MillimetersOfMercury = public unit(Pressure) as mmHg = 133.322387415Pa;
  Millibars = public unit(Pressure) as mbar = 100Pa;

  const c = 299792458mps; public;
  const g0 = 9.80665mps²; public;
  const G = 0.000000000066743 GravitationalConstantUnits; public;

end.