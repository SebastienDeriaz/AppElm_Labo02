'# MWS Version: Version 2022.3 - Feb 04 2022 - ACIS 31.0.1 -

'# length = mm
'# frequency = GHz
'# time = ns
'# frequency range: fmin = 0 fmax = 4
'# created = '[VERSION]2022.0|31.0.1|20210823[/VERSION]


'@ use template: Antenna_AppElm.cfg

'[VERSION]2022.0|31.0.1|20210823[/VERSION]
'set the units
With Units
    .Geometry "mm"
    .Frequency "GHz"
    .Voltage "V"
    .Resistance "Ohm"
    .Inductance "NanoH"
    .TemperatureUnit  "Kelvin"
    .Time "ns"
    .Current "A"
    .Conductance "Siemens"
    .Capacitance "PikoF"
End With

'----------------------------------------------------------------------------

'set the frequency range
Solver.FrequencyRange "0", "4"

'----------------------------------------------------------------------------

Plot.DrawBox True

With Background
     .Type "Normal"
     .Epsilon "1.0"
     .Mu "1.0"
     .XminSpace "0.0"
     .XmaxSpace "0.0"
     .YminSpace "0.0"
     .YmaxSpace "0.0"
     .ZminSpace "0.0"
     .ZmaxSpace "0.0"
End With

With Boundary
     .Xmin "expanded open"
     .Xmax "expanded open"
     .Ymin "expanded open"
     .Ymax "expanded open"
     .Zmin "expanded open"
     .Zmax "expanded open"
     .Xsymmetry "none"
     .Ysymmetry "none"
     .Zsymmetry "none"
End With

' optimize mesh settings for planar structures

With Mesh
     .MergeThinPECLayerFixpoints "True"
     .RatioLimit "20"
     .AutomeshRefineAtPecLines "True", "6"
     .FPBAAvoidNonRegUnite "True"
     .ConsiderSpaceForLowerMeshLimit "False"
     .MinimumStepNumber "5"
     .AnisotropicCurvatureRefinement "True"
     .AnisotropicCurvatureRefinementFSM "True"
End With

With MeshSettings
     .SetMeshType "Hex"
     .Set "RatioLimitGeometry", "20"
     .Set "EdgeRefinementOn", "1"
     .Set "EdgeRefinementRatio", "6"
End With

With MeshSettings
     .SetMeshType "HexTLM"
     .Set "RatioLimitGeometry", "20"
End With

With MeshSettings
     .SetMeshType "Tet"
     .Set "VolMeshGradation", "1.5"
     .Set "SrfMeshGradation", "1.5"
End With

' change mesh adaption scheme to energy
' 		(planar structures tend to store high energy
'     	 locally at edges rather than globally in volume)

MeshAdaption3D.SetAdaptionStrategy "Energy"

' switch on FD-TET setting for accurate farfields

FDSolver.ExtrudeOpenBC "True"

PostProcess1D.ActivateOperation "vswr", "true"
PostProcess1D.ActivateOperation "yz-matrices", "true"

With FarfieldPlot
	.ClearCuts ' lateral=phi, polar=theta
	.AddCut "lateral", "0", "1"
	.AddCut "lateral", "90", "1"
	.AddCut "polar", "90", "1"
End With

'----------------------------------------------------------------------------

Dim sDefineAt As String
sDefineAt = "2.45"
Dim sDefineAtName As String
sDefineAtName = "2.45"
Dim sDefineAtToken As String
sDefineAtToken = "f="
Dim aFreq() As String
aFreq = Split(sDefineAt, ";")
Dim aNames() As String
aNames = Split(sDefineAtName, ";")

Dim nIndex As Integer
For nIndex = LBound(aFreq) To UBound(aFreq)

Dim zz_val As String
zz_val = aFreq (nIndex)
Dim zz_name As String
zz_name = sDefineAtToken & aNames (nIndex)

' Define H-Field Monitors
With Monitor
    .Reset
    .Name "h-field ("& zz_name &")"
    .Dimension "Volume"
    .Domain "Frequency"
    .FieldType "Hfield"
    .MonitorValue  zz_val
    .Create
End With

' Define Farfield Monitors
With Monitor
    .Reset
    .Name "farfield ("& zz_name &")"
    .Domain "Frequency"
    .FieldType "Farfield"
    .MonitorValue  zz_val
    .ExportFarfieldSource "False"
    .Create
End With

Next

'----------------------------------------------------------------------------

With MeshSettings
     .SetMeshType "Hex"
     .Set "Version", 1%
End With

With Mesh
     .MeshType "PBA"
End With

'set the solver type
ChangeSolverType("HF Time Domain")

'----------------------------------------------------------------------------

'@ define material: FR-4 (loss free)

'[VERSION]2022.0|31.0.1|20210823[/VERSION]
With Material
     .Reset
     .Name "FR-4 (loss free)"
     .Folder ""
.FrqType "all"
.Type "Normal"
.SetMaterialUnit "GHz", "mm"
.Epsilon "4.3"
.Mu "1.0"
.Kappa "0.0"
.TanD "0.0"
.TanDFreq "0.0"
.TanDGiven "False"
.TanDModel "ConstTanD"
.KappaM "0.0"
.TanDM "0.0"
.TanDMFreq "0.0"
.TanDMGiven "False"
.TanDMModel "ConstKappa"
.DispModelEps "None"
.DispModelMu "None"
.DispersiveFittingSchemeEps "General 1st"
.DispersiveFittingSchemeMu "General 1st"
.UseGeneralDispersionEps "False"
.UseGeneralDispersionMu "False"
.Rho "0.0"
.ThermalType "Normal"
.ThermalConductivity "0.3"
.SetActiveMaterial "all"
.Colour "0.75", "0.95", "0.85"
.Wireframe "False"
.Transparency "0"
.Create
End With

'@ new component: component1

'[VERSION]2022.0|31.0.1|20210823[/VERSION]
Component.New "component1"

'@ define brick: component1:substrat

'[VERSION]2022.0|31.0.1|20210823[/VERSION]
With Brick
     .Reset 
     .Name "substrat" 
     .Component "component1" 
     .Material "FR-4 (loss free)" 
     .Xrange "-ls/2", "ls/2" 
     .Yrange "-ws/2", "ws/2" 
     .Zrange "0", "h" 
     .Create
End With

'@ define brick: component1:dip1

'[VERSION]2022.0|31.0.1|20210823[/VERSION]
With Brick
     .Reset 
     .Name "dip1" 
     .Component "component1" 
     .Material "PEC" 
     .Xrange "wl/2", "wl/2+i" 
     .Yrange "-ws/2", "-ws/2+l1" 
     .Zrange "h", "h+e" 
     .Create
End With

'@ define brick: component1:dip2

'[VERSION]2022.0|31.0.1|20210823[/VERSION]
With Brick
     .Reset 
     .Name "dip2" 
     .Component "component1" 
     .Material "PEC" 
     .Xrange "wl/2", "wl/2+l2" 
     .Yrange "-ws/2+l1+i", "-ws/2+l1" 
     .Zrange "h", "h+e" 
     .Create
End With

'@ transform: mirror component1:dip1

'[VERSION]2022.0|31.0.1|20210823[/VERSION]
With Transform 
     .Reset 
     .Name "component1:dip1" 
     .Origin "Free" 
     .Center "0", "0", "0" 
     .PlaneNormal "1", "0", "0" 
     .MultipleObjects "True" 
     .GroupObjects "False" 
     .Repetitions "1" 
     .MultipleSelection "True" 
     .Destination "" 
     .Material "" 
     .Transform "Shape", "Mirror" 
End With

'@ transform: mirror component1:dip2

'[VERSION]2022.0|31.0.1|20210823[/VERSION]
With Transform 
     .Reset 
     .Name "component1:dip2" 
     .Origin "Free" 
     .Center "0", "0", "0" 
     .PlaneNormal "1", "0", "0" 
     .MultipleObjects "True" 
     .GroupObjects "False" 
     .Repetitions "1" 
     .MultipleSelection "False" 
     .Destination "" 
     .Material "" 
     .Transform "Shape", "Mirror" 
End With

'@ define discrete port: 1

'[VERSION]2022.0|31.0.1|20210823[/VERSION]
With DiscretePort 
     .Reset 
     .PortNumber "1" 
     .Type "SParameter"
     .Label ""
     .Folder ""
     .Impedance "50.0"
     .VoltagePortImpedance "0.0"
     .Voltage "1.0"
     .Current "1.0"
     .Monitor "True"
     .Radius "0.0"
     .SetP1 "False", "-wl/2", "-ws/2", "h+e"
     .SetP2 "False", "wl/2", "-ws/2", "h+e"
     .InvertDirection "False"
     .LocalCoordinates "False"
     .Wire ""
     .Position "end1"
     .Create 
End With

'@ create group: meshgroup1

'[VERSION]2022.0|31.0.1|20210823[/VERSION]
Group.Add "meshgroup1", "mesh"

'@ set local mesh properties for: meshgroup1

'[VERSION]2022.0|31.0.1|20210823[/VERSION]
With MeshSettings
     With .ItemMeshSettings ("group$meshgroup1")
          .SetMeshType "Hex"
          .Set "EdgeRefinement", "1"
          .Set "Extend", "i/3", "i/3", "i/3"
          .Set "Fixpoints", 1
          .Set "MeshType", "Default"
          .Set "NumSteps", "0", "0", "0"
          .Set "Priority", "0"
          .Set "RefinementPolicy", "ABS_VALUE"
          .Set "SnappingIntervals", 0, 0, 0
          .Set "SnappingPriority", 0
          .Set "SnapTo", "1", "1", "1"
          .Set "Step", "i/3", "i/3", "i/3"
          .Set "StepRatio", "0", "0", "0"
          .Set "StepRefinementCollectPolicy", "REFINE_ALL"
          .Set "StepRefinementExtentPolicy", "EXTENT_ABS_VALUE"
          .Set "UseDielectrics", 1
          .Set "UseEdgeRefinement", 0
          .Set "UseForRefinement", 1
          .Set "UseForSnapping", 1
          .Set "UseSameExtendXYZ", 1
          .Set "UseSameStepWidthXYZ", 1
          .Set "UseSnappingPriority", 0
          .Set "UseStepAndExtend", 1
          .Set "UseVolumeRefinement", 0
          .Set "VolumeRefinement", "1"
     End With
End With

'@ add items to group: "meshgroup1"

'[VERSION]2022.0|31.0.1|20210823[/VERSION]
Group.AddItem "solid$component1:dip1", "meshgroup1"
Group.AddItem "solid$component1:dip1_1", "meshgroup1"
Group.AddItem "solid$component1:dip2", "meshgroup1"
Group.AddItem "solid$component1:dip2_1", "meshgroup1"

'@ define time domain solver parameters

'[VERSION]2022.0|31.0.1|20210823[/VERSION]
Mesh.SetCreator "High Frequency" 

With Solver 
     .Method "Hexahedral"
     .CalculationType "TD-S"
     .StimulationPort "All"
     .StimulationMode "All"
     .SteadyStateLimit "-40"
     .MeshAdaption "False"
     .AutoNormImpedance "False"
     .NormingImpedance "50"
     .CalculateModesOnly "False"
     .SParaSymmetry "False"
     .StoreTDResultsInCache  "False"
     .RunDiscretizerOnly "False"
     .FullDeembedding "False"
     .SuperimposePLWExcitation "False"
     .UseSensitivityAnalysis "False"
End With

'@ set PBA version

'[VERSION]2022.0|31.0.1|20210823[/VERSION]
Discretizer.PBAVersion "2021082322"

'@ define time domain solver acceleration

'[VERSION]2022.0|31.0.1|20210823[/VERSION]
With Solver 
     .UseParallelization "True"
     .MaximumNumberOfThreads "1024"
     .MaximumNumberOfCPUDevices "4"
     .RemoteCalculation "False"
     .UseDistributedComputing "False"
     .MaxNumberOfDistributedComputingPorts "64"
     .DistributeMatrixCalculation "True"
     .MPIParallelization "False"
     .AutomaticMPI "False"
     .HardwareAcceleration "True"
     .MaximumNumberOfGPUs "1"
End With
UseDistributedComputingForParameters "False"
MaxNumberOfDistributedComputingParameters "2"
UseDistributedComputingMemorySetting "False"
MinDistributedComputingMemoryLimit "0"
UseDistributedComputingSharedDirectory "False"
OnlyConsider0D1DResultsForDC "False"

'@ pick edge

'[VERSION]2022.0|31.0.1|20210823[/VERSION]
Pick.PickEdgeFromId "component1:dip2_1", "2", "2"

'@ define distance dimension

'[VERSION]2022.0|31.0.1|20210823[/VERSION]
With Dimension
    .Reset
    .CreationType "picks"
    .SetType "Distance"
    .SetID "0"
    .SetOrientation "Smart Mode"
    .SetDistance "4.065565"
    .SetViewVector "-0.000000", "-0.000009", "-1.000000"
    .SetConnectedElement1 "component1:dip2_1"
    .SetConnectedElement2 "component1:dip2_1"
    .Create
End With

Pick.ClearAllPicks

'@ pick end point

'[VERSION]2022.0|31.0.1|20210823[/VERSION]
Pick.PickEndpointFromId "component1:dip2", "2"

'@ unpick end point

'[VERSION]2022.0|31.0.1|20210823[/VERSION]
Pick.UnpickEndpointFromId "component1:dip2", "2"

'@ pick edge

'[VERSION]2022.0|31.0.1|20210823[/VERSION]
Pick.PickEdgeFromId "component1:dip2", "2", "2"

'@ define distance dimension

'[VERSION]2022.0|31.0.1|20210823[/VERSION]
With Dimension
    .Reset
    .CreationType "picks"
    .SetType "Distance"
    .SetID "1"
    .SetOrientation "Smart Mode"
    .SetDistance "4.010827"
    .SetViewVector "0.003491", "-0.000009", "-0.999994"
    .SetConnectedElement1 "component1:dip2"
    .SetConnectedElement2 "component1:dip2"
    .Create
End With

Pick.ClearAllPicks

'@ pick edge

'[VERSION]2022.0|31.0.1|20210823[/VERSION]
Pick.PickEdgeFromId "component1:dip1", "1", "1"

'@ define distance dimension

'[VERSION]2022.0|31.0.1|20210823[/VERSION]
With Dimension
    .Reset
    .CreationType "picks"
    .SetType "Distance"
    .SetID "2"
    .SetOrientation "Smart Mode"
    .SetDistance "20.763327"
    .SetViewVector "0.003491", "-0.000009", "-0.999994"
    .SetConnectedElement1 "component1:dip1"
    .SetConnectedElement2 "component1:dip1"
    .Create
End With

Pick.ClearAllPicks

'@ delete dimension 1

'[VERSION]2022.0|31.0.1|20210823[/VERSION]
With Dimension
    .RemoveDimension "1"
End With

'@ pick edge

'[VERSION]2022.0|31.0.1|20210823[/VERSION]
Pick.PickEdgeFromId "component1:dip2", "1", "1"

'@ define distance dimension

'[VERSION]2022.0|31.0.1|20210823[/VERSION]
With Dimension
    .Reset
    .CreationType "picks"
    .SetType "Distance"
    .SetID "3"
    .SetOrientation "Smart Mode"
    .SetDistance "2.946012"
    .SetViewVector "0.003491", "-0.000009", "-0.999994"
    .SetConnectedElement1 "component1:dip2"
    .SetConnectedElement2 "component1:dip2"
    .Create
End With

Pick.ClearAllPicks

'@ pick end point

'[VERSION]2022.0|31.0.1|20210823[/VERSION]
Pick.PickEndpointFromId "component1:dip1_1", "4"

'@ pick end point

'[VERSION]2022.0|31.0.1|20210823[/VERSION]
Pick.PickEndpointFromId "component1:dip1", "4"

'@ define distance dimension

'[VERSION]2022.0|31.0.1|20210823[/VERSION]
With Dimension
    .Reset
    .CreationType "picks"
    .SetType "Distance"
    .SetID "4"
    .SetOrientation "Smart Mode"
    .SetDistance "20.193699"
    .SetViewVector "0.003491", "-0.000009", "-0.999994"
    .SetConnectedElement1 "component1:dip1_1"
    .SetConnectedElement2 "component1:dip1"
    .Create
End With

Pick.ClearAllPicks

'@ change dimension 3

'[VERSION]2022.0|31.0.1|20210823[/VERSION]
With Dimension
    .Reset
    .SetID "3"
    .SetDistance "2.946012"
    .SetOrientation "Smart Mode"
    .SetViewVector "0.003491", "-0.000009", "-0.999994"
    .Modify
End With

'@ delete dimension 3

'[VERSION]2022.0|31.0.1|20210823[/VERSION]
With Dimension
    .RemoveDimension "3"
End With

'@ pick edge

'[VERSION]2022.0|31.0.1|20210823[/VERSION]
Pick.PickEdgeFromId "component1:dip2", "1", "1"

'@ define distance dimension

'[VERSION]2022.0|31.0.1|20210823[/VERSION]
With Dimension
    .Reset
    .CreationType "picks"
    .SetType "Distance"
    .SetID "5"
    .SetOrientation "Smart Mode"
    .SetDistance "1.563614"
    .SetViewVector "0.003491", "-0.000009", "-0.999994"
    .SetConnectedElement1 "component1:dip2"
    .SetConnectedElement2 "component1:dip2"
    .Create
End With

Pick.ClearAllPicks

'@ define time domain solver acceleration

'[VERSION]2022.0|31.0.1|20210823[/VERSION]
With Solver 
     .UseParallelization "True"
     .MaximumNumberOfThreads "1024"
     .MaximumNumberOfCPUDevices "4"
     .RemoteCalculation "False"
     .UseDistributedComputing "False"
     .MaxNumberOfDistributedComputingPorts "64"
     .DistributeMatrixCalculation "True"
     .MPIParallelization "False"
     .AutomaticMPI "False"
     .HardwareAcceleration "True"
     .MaximumNumberOfGPUs "1"
End With
UseDistributedComputingForParameters "False"
MaxNumberOfDistributedComputingParameters "2"
UseDistributedComputingMemorySetting "False"
MinDistributedComputingMemoryLimit "0"
UseDistributedComputingSharedDirectory "False"
OnlyConsider0D1DResultsForDC "False"

'@ pick edge

'[VERSION]2022.0|31.0.1|20210823[/VERSION]
Pick.PickEdgeFromId "component1:substrat", "2", "2"

'@ define distance dimension

'[VERSION]2022.0|31.0.1|20210823[/VERSION]
With Dimension
    .Reset
    .CreationType "picks"
    .SetType "Distance"
    .SetID "6"
    .SetOrientation "Smart Mode"
    .SetDistance "9.847107"
    .SetViewVector "0.003491", "-0.000019", "-0.999994"
    .SetConnectedElement1 "component1:substrat"
    .SetConnectedElement2 "component1:substrat"
    .Create
End With

Pick.ClearAllPicks

'@ define material: Alumina (96%) (loss free)

'[VERSION]2022.0|31.0.1|20210823[/VERSION]
With Material
     .Reset
     .Name "Alumina (96%) (loss free)"
     .Folder ""
.FrqType "all"
.Type "Normal"
.SetMaterialUnit "MHz", "mm"
.Epsilon "9.4"
.Mu "1.0"
.Kappa "0.0"
.TanD "0.0"
.TanDFreq "0.0"
.TanDGiven "False"
.TanDModel "ConstTanD"
.KappaM "0.0"
.TanDM "0.0"
.TanDMFreq "0.0"
.TanDMGiven "False"
.TanDMModel "ConstKappa"
.DispModelEps "None"
.DispModelMu "None"
.DispersiveFittingSchemeEps "General 1st"
.DispersiveFittingSchemeMu "General 1st"
.UseGeneralDispersionEps "False"
.UseGeneralDispersionMu "False"
.Rho "3800.0"
.ThermalType "Normal"
.ThermalConductivity "25"
.SpecificHeat "880", "J/K/kg"
.MechanicsType "Isotropic"
.YoungsModulus "300"
.PoissonsRatio "0.22"
.ThermalExpansionRate "7"
.Colour "0.75", "0.95", "0.85"
.Wireframe "False"
.Transparency "0"
.Create
End With

'@ change material: component1:substrat to: Alumina (96%) (loss free)

'[VERSION]2022.0|31.0.1|20210823[/VERSION]
Solid.ChangeMaterial "component1:substrat", "Alumina (96%) (loss free)"

'@ farfield plot options

'[VERSION]2022.3|31.0.1|20220204[/VERSION]
With FarfieldPlot 
     .Plottype "3D" 
     .Vary "angle1" 
     .Theta "90" 
     .Phi "90" 
     .Step "5" 
     .Step2 "5" 
     .SetLockSteps "True" 
     .SetPlotRangeOnly "False" 
     .SetThetaStart "0" 
     .SetThetaEnd "180" 
     .SetPhiStart "0" 
     .SetPhiEnd "360" 
     .SetTheta360 "False" 
     .SymmetricRange "False" 
     .SetTimeDomainFF "False" 
     .SetFrequency "-1" 
     .SetTime "0" 
     .SetColorByValue "True" 
     .DrawStepLines "False" 
     .DrawIsoLongitudeLatitudeLines "False" 
     .ShowStructure "False" 
     .ShowStructureProfile "False" 
     .SetStructureTransparent "False" 
     .SetFarfieldTransparent "False" 
     .AspectRatio "Free" 
     .ShowGridlines "True" 
     .InvertAxes "False", "False" 
     .SetSpecials "enablepolarextralines" 
     .SetPlotMode "Gain" 
     .Distance "1" 
     .UseFarfieldApproximation "True" 
     .IncludeUnitCellSidewalls "True" 
     .SetScaleLinear "False" 
     .SetLogRange "40" 
     .SetLogNorm "0" 
     .DBUnit "0" 
     .SetMaxReferenceMode "abs" 
     .EnableFixPlotMaximum "False" 
     .SetFixPlotMaximumValue "1.0" 
     .SetInverseAxialRatio "False" 
     .SetAxesType "user" 
     .SetAntennaType "isotropic" 
     .Phistart "1.000000e+00", "0.000000e+00", "0.000000e+00" 
     .Thetastart "0.000000e+00", "0.000000e+00", "1.000000e+00" 
     .PolarizationVector "0.000000e+00", "1.000000e+00", "0.000000e+00" 
     .SetCoordinateSystemType "spherical" 
     .SetAutomaticCoordinateSystem "True" 
     .SetPolarizationType "Abs" 
     .SlantAngle 0.000000e+00 
     .Origin "bbox" 
     .Userorigin "0.000000e+00", "0.000000e+00", "0.000000e+00" 
     .SetUserDecouplingPlane "False" 
     .UseDecouplingPlane "False" 
     .DecouplingPlaneAxis "X" 
     .DecouplingPlanePosition "0.000000e+00" 
     .LossyGround "False" 
     .GroundEpsilon "1" 
     .GroundKappa "0" 
     .EnablePhaseCenterCalculation "False" 
     .SetPhaseCenterAngularLimit "3.000000e+01" 
     .SetPhaseCenterComponent "boresight" 
     .SetPhaseCenterPlane "both" 
     .ShowPhaseCenter "True" 
     .ClearCuts 
     .AddCut "lateral", "0", "1"  
     .AddCut "lateral", "90", "1"  
     .AddCut "polar", "90", "1"  

     .StoreSettings
End With

