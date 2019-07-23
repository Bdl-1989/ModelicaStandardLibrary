within Modelica.Electrical.QuasiStatic.Polyphase.Interfaces;
partial model AbsoluteSensor "Partial potential sensor"
  extends Modelica.Icons.RoundSensor;
  parameter Integer m(min=1) = 3 "Number of phases";
  Modelica.SIunits.AngularVelocity omega;
  PositivePlug plug_p(final m=m)
    "Positive quasi-static polyphase plug" annotation (Placement(
        transformation(extent={{-110,-10},{-90,10}})));
equation
  omega = der(plug_p.reference.gamma);
  annotation (Icon(graphics={
        Line(points={{-70,0},{-94,0}}, color={85,170,255}),
        Line(points={{70,0},{80,0},{90,0},{100,0}}),
        Text(
          extent={{150,-100},{-150,-70}},
          textString="m=%m"),
        Text(
          textColor={0,0,255},
          extent={{-150,80},{150,120}},
          textString="%name")}), Documentation(info="<html>

<p>
The absolute sensor partial model relies on the a
<a href=\"modelica://Modelica.Electrical.QuasiStatic.Polyphase.Interfaces.PositivePlug\">positive plug</a> to measure the complex potential. Additionally this model contains a proper icon and a definition of the angular velocity.
</p>

<h4>See also</h4>

<p>
<a href=\"modelica://Modelica.Electrical.QuasiStatic.Polyphase.Interfaces.RelativeSensor\">RelativeSensor</a>,
<a href=\"modelica://Modelica.Electrical.QuasiStatic.SinglePhase.Interfaces.AbsoluteSensor\">SinglePhase.Interfaces.AbsoluteSensor</a>,
<a href=\"modelica://Modelica.Electrical.QuasiStatic.SinglePhase.Interfaces.RelativeSensor\">SinglePhase.Interfaces.RelativeSensor</a>
</p>

</html>"));
end AbsoluteSensor;
