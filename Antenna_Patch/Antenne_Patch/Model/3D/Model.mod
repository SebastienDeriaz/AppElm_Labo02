'# MWS Version: Version 2022.0 - Aug 23 2021 - ACIS 31.0.1 -

'# length = mm
'# frequency = GHz
'# time = ns
'# frequency range: fmin = 0 fmax = 6
'# created = '[VERSION]2022.0|31.0.1|20210823[/VERSION]


'@ use template: Antenna_patch.cfg

'[VERSION]2022.0|31.0.1|20210823[/VERSION]
'set the units
With Units
    .Geometry "mm"
    .Frequency "GHz"
    .Voltage "V"
    .Resistance "Ohm"
    .Inductance "H"
    .TemperatureUnit  "Kelvin"
    .Time "ns"
    .Current "A"
    .Conductance "Siemens"
    .Capacitance "F"
End With

'----------------------------------------------------------------------------

'set the frequency range
Solver.FrequencyRange "1", "4"

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

' Define E-Field Monitors
With Monitor
    .Reset
    .Name "e-field ("& zz_name &")"
    .Dimension "Volume"
    .Domain "Frequency"
    .FieldType "Efield"
    .MonitorValue  zz_val
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
     .Yrange "0", "ws" 
     .Zrange "-h", "0" 
     .Create
End With

'@ new component: component2

'[VERSION]2022.0|31.0.1|20210823[/VERSION]
Component.New "component2"

'@ define brick: component2:Pied

'[VERSION]2022.0|31.0.1|20210823[/VERSION]
With Brick
     .Reset 
     .Name "Pied" 
     .Component "component2" 
     .Material "PEC" 
     .Xrange "-w0/2", "w0/2" 
     .Yrange "0", "y0+y1" 
     .Zrange "0", "e" 
     .Create
End With

'@ define brick: component2:Haut_centre

'[VERSION]2022.0|31.0.1|20210823[/VERSION]
With Brick
     .Reset 
     .Name "Haut_centre" 
     .Component "component2" 
     .Material "PEC" 
     .Xrange "-w0/2-w1", "w0/2+w1" 
     .Yrange "y0+y1", "y1+L" 
     .Zrange "0", "e" 
     .Create
End With

'@ define brick: component2:Gauche

'[VERSION]2022.0|31.0.1|20210823[/VERSION]
With Brick
     .Reset 
     .Name "Gauche" 
     .Component "component2" 
     .Material "PEC" 
     .Xrange "-W/2", "-w0/2-w1" 
     .Yrange "y1", "y1+L" 
     .Zrange "0", "e" 
     .Create
End With

'@ define brick: component2:Droit

'[VERSION]2022.0|31.0.1|20210823[/VERSION]
With Brick
     .Reset 
     .Name "Droit" 
     .Component "component2" 
     .Material "PEC" 
     .Xrange "w0/2+w1", "W/2" 
     .Yrange "y1", "y1+L" 
     .Zrange "0", "e" 
     .Create
End With

'@ new component: component3

'[VERSION]2022.0|31.0.1|20210823[/VERSION]
Component.New "component3"

'@ define brick: component3:GND

'[VERSION]2022.0|31.0.1|20210823[/VERSION]
With Brick
     .Reset 
     .Name "GND" 
     .Component "component3" 
     .Material "PEC" 
     .Xrange "-ls/2", "ls/2" 
     .Yrange "0", "ws" 
     .Zrange "-h", "-h-e" 
     .Create
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
     .SetP1 "False", "0.0", "0", "-h"
     .SetP2 "False", "0.0", "0", "0"
     .InvertDirection "False"
     .LocalCoordinates "False"
     .Wire ""
     .Position "end1"
     .Create 
End With

'@ define frequency range

'[VERSION]2022.0|31.0.1|20210823[/VERSION]
Solver.FrequencyRange "0", "6"

