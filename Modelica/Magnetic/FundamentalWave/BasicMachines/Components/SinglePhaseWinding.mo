within Modelica.Magnetic.FundamentalWave.BasicMachines.Components;
model SinglePhaseWinding
  "Symmetric winding model coupling electrical and magnetic domain"

  Modelica.Electrical.Analog.Interfaces.PositivePin pin_p "Positive pin"
    annotation (Placement(transformation(
        origin={-100,100},
        extent={{-10,-10},{10,10}},
        rotation=180)));
  Modelica.Electrical.Analog.Interfaces.NegativePin pin_n "Negative pin"
    annotation (Placement(transformation(
        origin={-100,-100},
        extent={{-10,-10},{10,10}},
        rotation=180)));
  Magnetic.FundamentalWave.Interfaces.NegativeMagneticPort port_n
    "Negative complex magnetic port"
    annotation (Placement(transformation(extent={{90,-110},{110,-90}})));
  Magnetic.FundamentalWave.Interfaces.PositiveMagneticPort port_p
    "Positive complex magnetic port"
    annotation (Placement(transformation(extent={{90,90},{110,110}})));
  parameter Boolean useHeatPort=false
    "Enable / disable (=fixed temperatures) thermal port"
    annotation (Evaluate=true);
  parameter SI.Resistance RRef
    "Winding resistance per phase at TRef";
  parameter SI.Temperature TRef(start=293.15)
    "Reference temperature of winding";
  parameter
    Modelica.Electrical.Machines.Thermal.LinearTemperatureCoefficient20
    alpha20(start=0) "Temperature coefficient of winding at 20 degC";
  final parameter SI.LinearTemperatureCoefficient alphaRef=
      Modelica.Electrical.Machines.Thermal.convertAlpha(
            alpha20,
            TRef,
            293.15) "Temperature coefficient of winding at reference temperature";
  parameter SI.Temperature TOperational(start=293.15)
    "Operational temperature of winding"
    annotation (Dialog(enable=not useHeatPort));
  parameter SI.Inductance Lsigma
    "Winding stray inductance per phase";
  parameter Real effectiveTurns=1 "Effective number of turns per phase";
  parameter SI.Angle orientation
    "Orientation of the resulting fundamental wave field phasor";

  SI.Voltage v=pin_p.v - pin_n.v "Voltage";
  SI.Current i=pin_p.i "Current";

  SI.ComplexMagneticPotentialDifference V_m=port_p.V_m -
      port_n.V_m "Complex magnetic potential difference";
  SI.MagneticPotentialDifference abs_V_m=
      Modelica.ComplexMath.abs(V_m)
    "Magnitude of complex magnetic potential difference";
  SI.Angle arg_V_m=Modelica.ComplexMath.arg(V_m)
    "Argument of complex magnetic potential difference";
  SI.ComplexMagneticFlux Phi=port_p.Phi
    "Complex magnetic flux";
  SI.MagneticFlux abs_Phi=
      Modelica.ComplexMath.abs(Phi)
    "Magnitude of complex magnetic flux";
  SI.Angle arg_Phi=Modelica.ComplexMath.arg(Phi)
    "Argument of complex magnetic flux";

  Modelica.Electrical.Analog.Basic.Resistor resistor(
    final useHeatPort=useHeatPort,
    final R=RRef,
    final T_ref=TRef,
    final alpha=alphaRef,
    final T=TOperational) annotation (Placement(transformation(
        origin={-10,70},
        extent={{10,10},{-10,-10}},
        rotation=90)));
  Magnetic.FundamentalWave.Components.SinglePhaseElectroMagneticConverter electroMagneticConverter(final
      effectiveTurns=effectiveTurns, final orientation=orientation) "Winding"
    annotation (Placement(transformation(extent={{-10,-10},{10,10}})));
  Modelica.Thermal.HeatTransfer.Interfaces.HeatPort_a heatPortWinding if
    useHeatPort "Heat ports of winding resistor"
    annotation (Placement(transformation(extent={{-10,-110},{10,-90}})));
  Modelica.Magnetic.FundamentalWave.Components.Permeance stray(final G_m(d=
          Lsigma/effectiveTurns^2, q=Lsigma/effectiveTurns^2)) annotation (
      Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=270,
        origin={30,0})));
equation
  connect(pin_p, resistor.p) annotation (Line(points={{-100,100},{-10,100},
          {-10,80}}, color={0,0,255}));
  connect(electroMagneticConverter.pin_n, pin_n) annotation (Line(points=
          {{-10,-10},{-10,-100},{-100,-100}}, color={0,0,255}));
  connect(electroMagneticConverter.port_p, port_p) annotation (Line(
        points={{10,10},{10,100},{100,100}}, color={255,128,0}));
  connect(electroMagneticConverter.port_n, port_n) annotation (Line(
        points={{10,-10},{10,-100},{100,-100}}, color={255,128,0}));
  connect(heatPortWinding, resistor.heatPort) annotation (Line(
      points={{0,-100},{0,-60},{-40,-60},{-40,70},{-20,70}}, color={191,0,0}));
  connect(resistor.n, electroMagneticConverter.pin_p) annotation (Line(
      points={{-10,60},{-10,10}}, color={0,0,255}));
  connect(electroMagneticConverter.port_p, stray.port_p)
    annotation (Line(points={{10,10},{30,10}}, color={255,128,0}));
  connect(electroMagneticConverter.port_n, stray.port_n)
    annotation (Line(points={{10,-10},{30,-10}}, color={255,128,0}));
  annotation (defaultComponentName="winding", Icon(coordinateSystem(preserveAspectRatio=false, extent={{-100,
            -100},{100,100}}), graphics={      Line(points={{100,-100},{
          94,-100},{84,-98},{76,-94},{64,-86},{50,-72},{42,-58},{36,-40},
          {30,-18},{30,0},{30,18},{34,36},{46,66},{62,84},{78,96},{90,100},
          {100,100}}, color={255,128,0}),Line(points={{40,60},{-100,60},{
          -100,100}}, color={0,0,255}),Line(points={{40,-60},{-100,-60},{
          -100,-98}}, color={0,0,255}),Line(points={{40,60},{100,20},{40,
          -20},{0,-20},{-40,0},{0,20},{40,20},{100,-20},{40,-60}}, color=
          {0,0,255}),
          Text(
              extent={{-150,110},{150,150}},
              textColor={0,0,255},
              textString="%name")}),   Documentation(info="<html>
<p>
The single-phase winding consists of a winding
<a href=\"modelica://Modelica.Electrical.Analog.Basic.Resistor\">resistor</a>, a
<a href=\"modelica://Modelica.Magnetic.FundamentalWave.Components.SinglePhaseElectroMagneticConverter\">single-phase electromagnetic coupling</a> and a <a href=\"modelica://Modelica.Magnetic.FundamentalWave.Components.Reluctance\">stray reluctance</a>.
</p>

<h4>See also</h4>
<p>
<a href=\"modelica://Modelica.Magnetic.FundamentalWave.BasicMachines.Components.SymmetricPolyphaseWinding\">SymmetricPolyphaseWinding</a>,
<a href=\"modelica://Modelica.Magnetic.FundamentalWave.BasicMachines.Components.SymmetricPolyphaseCageWinding\">SymmetricPolyphaseCageWinding</a>,
<a href=\"modelica://Modelica.Magnetic.FundamentalWave.BasicMachines.Components.SaliencyCageWinding\">SaliencyCageWinding</a>
<a href=\"modelica://Modelica.Magnetic.FundamentalWave.BasicMachines.Components.RotorSaliencyAirGap\">RotorSaliencyAirGap</a>
</p>
</html>"));
end SinglePhaseWinding;
