within Modelica.Math;
package Random "Library of functions for generating random numbers"
   extends Modelica.Icons.Package;

  package Examples
    "Examples demonstrating the usage of the functions in package Random"
    extends Modelica.Icons.ExamplesPackage;

    model GenerateRandomNumbers
      "Generate random numbers with the various random number generators"
       extends Modelica.Icons.Example;

    // Global parameters
      parameter Modelica.SIunits.Period samplePeriod = 0.05
        "Sample period for the generation of random numbers";
      parameter Integer globalSeed = 30020
        "Global seed to initialize random number generator";

    // Random number generators with exposed state
      parameter Integer localSeed = 614657
        "Local seed to initialize random number generator";
      output Real r64 "Random number generated with Xorshift64star";
      output Real r128 "Random number generated with Xorshift128plus";
      output Real r1024 "Random number generated with Xorshift1024star";
    protected
      discrete Integer state64[2](   each start=0, each fixed = true);
      discrete Integer state128[4](  each start=0, each fixed = true);
      discrete Integer state1024[33](each start=0, each fixed = true);
    algorithm
      when initial() then
        // Generate initial state from localSeed and globalSeed
        state64   := Generators.Xorshift64star.initialState(  localSeed, globalSeed);
        state128  := Generators.Xorshift128plus.initialState( localSeed, globalSeed);
        state1024 := Generators.Xorshift1024star.initialState(localSeed, globalSeed);
        r64       := 0;
        r128      := 0;
        r1024     := 0;
      elsewhen sample(0,samplePeriod) then
        (r64,  state64)   := Generators.Xorshift64star.random(  pre(state64));
        (r128, state128)  := Generators.Xorshift128plus.random( pre(state128));
        (r1024,state1024) := Generators.Xorshift1024star.random(pre(state1024));
      end when;

    // Impure random number generators with hidden state
    public
      Integer id "A unique number used to sort equations correctly";
      discrete Real rImpure "Impure Real random number";
      Integer iImpure "Impure Integer rndom number";
    algorithm
      when initial() then
        id := Utilities.initializeImpureRandom(globalSeed, time);
        rImpure := 0;
        iImpure := 0;
      elsewhen sample(0,samplePeriod) then
        rImpure := Utilities.impureRandom(id=id);
        iImpure := Utilities.impureRandomInteger(
              id=id,
              imin=-1234,
              imax=2345);
      end when;

      annotation (experiment(StopTime=2), Documentation(info="<html>
<p>
This example demonstrates how to utilize the random number generators
of package <a href=\"Modelica.Math.Random.Generators\">Math.Random.Generators</a> in a Modelica model.
The example calculates random numbers in the range 0 .. 1 of the available random number generators periodically
with a sample period of 0.05 s. Simulations results are shown in the figure below:
</p>

<p><blockquote>
<img src=\"modelica://Modelica/Resources/Images/Math/Random/GenerateRandomNumbers.png\">
</blockquote></p>
</html>",     revisions="<html>
<p>
<table border=1 cellspacing=0 cellpadding=2>
<tr><th>Date</th> <th align=\"left\">Description</th></tr>

<tr><td valign=\"top\"> June 22, 2015 </td>
    <td valign=\"top\">

<table border=0>
<tr><td valign=\"top\">
         <img src=\"modelica://Modelica/Resources/Images/Logos/dlr_logo.png\">
</td><td valign=\"bottom\">
         Initial version implemented by
         A. Kl&ouml;ckner, F. v.d. Linden, D. Zimmer, M. Otter.<br>
         <a href=\"http://www.dlr.de/rmc/sr/en\">DLR Institute of System Dynamics and Control</a>
</td></tr></table>
</td></tr>

</table>
</p>
</html>"));
    end GenerateRandomNumbers;
  annotation (Documentation(info="<html>
<p>
This package contains examples demonstrating the usage of the functions in package
<b>Random</b>.
</p>
</html>",   revisions="<html>
<p>
<table border=1 cellspacing=0 cellpadding=2>
<tr><th>Date</th> <th align=\"left\">Description</th></tr>

<tr><td valign=\"top\"> June 22, 2015 </td>
    <td valign=\"top\">

<table border=0>
<tr><td valign=\"top\">
         <img src=\"modelica://Modelica/Resources/Images/Logos/dlr_logo.png\">
</td><td valign=\"bottom\">
         Initial version implemented by
         A. Kl&ouml;ckner, F. v.d. Linden, D. Zimmer, M. Otter.<br>
         <a href=\"http://www.dlr.de/rmc/sr/en\">DLR Institute of System Dynamics and Control</a>
</td></tr></table>
</td></tr>

</table>
</p>
</html>"));
  end Examples;

  package Generators
    "Library of functions generating uniform random numbers in the range 0 < random <= 1.0 (with exposed state vectors)"
    extends Modelica.Icons.Package;

    package Xorshift64star "Random number generator xorshift64*"
      constant Integer nState=2 "The dimension of the internal state vector";

      extends Modelica.Icons.Package;

      function initialState
        "Returns an initial state for the xorshift64* algorithm"
        extends Modelica.Icons.Function;
        input Integer localSeed
          "The local seed to be used for generating initial states";
        input Integer globalSeed
          "The global seed to be combined with the local seed";
        output Integer state[nState] "The generated initial states";
      protected
        Real r "Random number not used outside the function";

        /* According to http://vigna.di.unimi.it/ftp/papers/xorshift.pdf, the xorshoft*
     random number generator generates statistically random numbers from a bad seed
      within one iteration. To be on the safe side, 10 iterations are actually used
    */
        constant Integer p = 10 "The number of iterations to use";

      algorithm
        // If seed=0 use a large prime number as seed (seed must be different from 0).
        if localSeed == 0 and globalSeed == 0 then
          state := {126247697,globalSeed};
        else
          state := {localSeed,globalSeed};
        end if;

        // Generate p-times a random number, in order to get a "good" state
        // even if starting from a bad seed.
        for i in 1:p loop
          (r,state) := random(state);
        end for;
      annotation (Documentation(info="<html>
<h4>Syntax</h4>
<blockquote><pre>
state = Xorshift64star.<b>initialState</b>(localSeed, globalSeed);
</pre></blockquote>

<h4>Description</h4>
<p>
Generates the initial state vector <b>state</b> for the Xorshift64star random number generator
(= xorshift64* algorithm), from
two Integer numbers given as input (arguments localSeed, globalSeed). Any Integer numbers
can be given (including zero or negative number). The function returns
a reasonable initial state vector with the following strategy:
</p>

<p>
If both input
arguments are zero, a fixed non-zero value is used internally for localSeed.
According to <a href=\"http://vigna.di.unimi.it/ftp/papers/xorshift.pdf\">xorshift.pdf</a>,
the xorshift64* random number generator generates statistically random numbers from a
bad seed within one iteration. To be on the safe side, actually 10 random numbers are generated
and the returned state is the one from the last iteration.
</p>

<h4>Example</h4>
<blockquote><pre>
  <b>parameter</b> Integer localSeed;
  <b>parameter</b> Integer globalSeed;
  Integer state[Xorshift64star.nState];
<b>initial equation</b>
  state = initialState(localSeed, globalSeed);
</pre></blockquote>

<h4>See also</h4>
<p>
<a href=\"modelica://Modelica.Math.Random.Generators.Xorshift64star.random\">Random.Generators.Xorshift64star.random</a>.
</p>
</html>",     revisions="<html>
<p>
<table border=1 cellspacing=0 cellpadding=2>
<tr><th>Date</th> <th align=\"left\">Description</th></tr>

<tr><td valign=\"top\"> June 22, 2015 </td>
    <td valign=\"top\">

<table border=0>
<tr><td valign=\"top\">
         <img src=\"modelica://Modelica/Resources/Images/Logos/dlr_logo.png\">
</td><td valign=\"bottom\">
         Initial version implemented by
         A. Kl&ouml;ckner, F. v.d. Linden, D. Zimmer, M. Otter.<br>
         <a href=\"http://www.dlr.de/rmc/sr/en\">DLR Institute of System Dynamics and Control</a>
</td></tr></table>
</td></tr>

</table>
</p>
</html>"));
      end initialState;

      function random
        "Returns a uniform random number with the xorshift64* algorithm"
        extends Modelica.Icons.Function;
        input Integer stateIn[nState]
          "The internal states for the random number generator";
        output Real result
          "A random number with a uniform distribution on the interval (0,1]";
        output Integer stateOut[nState]
          "The new internal states of the random number generator";
        external "C" ModelicaRandom_xorshift64star(stateIn, stateOut, result)
          annotation (Library="ModelicaExternalC");
        annotation(Documentation(info="<html>
<h4>Syntax</h4>
<blockquote><pre>
(r, stateOut) = Xorshift64star.<b>random</b>(stateIn);
</pre></blockquote>

<h4>Description</h4>
<p>
Returns a uniform random number r in the range 0 &lt; r &le; 1 with the xorshift64* algorithm.
Input argument <b>stateIn</b> is the state vector of the previous call.
Output argument <b>stateOut</b> is the updated state vector.
If the function is called with identical stateIn vectors, exactly the
same random number r is returned.
</p>

<h4>Example</h4>
<blockquote><pre>
  <b>parameter</b> Integer localSeed;
  <b>parameter</b> Integer globalSeed;
  Real r;
  Integer state[Xorshift64star.nState];
<b>initial equation</b>
  state = initialState(localSeed, globalSeed);
<b>equation</b>
  <b>when</b> sample(0,0.1) <b>then</b>
    (r, state) = random(<b>pre</b>(state));
  <b>end when</b>;
</pre></blockquote>

<h4>See also</h4>
<p>
<a href=\"modelica://Modelica.Math.Random.Generators.Xorshift64star.initialState\">Random.Generators.Xorshift64star.initialState</a>.
</p>
</html>",     revisions="<html>
<p>
<table border=1 cellspacing=0 cellpadding=2>
<tr><th>Date</th> <th align=\"left\">Description</th></tr>

<tr><td valign=\"top\"> June 22, 2015 </td>
    <td valign=\"top\">

<table border=0>
<tr><td valign=\"top\">
         <img src=\"modelica://Modelica/Resources/Images/Logos/dlr_logo.png\">
</td><td valign=\"bottom\">
         Initial version implemented by
         A. Kl&ouml;ckner, F. v.d. Linden, D. Zimmer, M. Otter.<br>
         <a href=\"http://www.dlr.de/rmc/sr/en\">DLR Institute of System Dynamics and Control</a>
</td></tr></table>
</td></tr>

</table>
</p>
</html>"));
      end random;
      annotation (Documentation(info="<html>
<p>
Random number generator <b>xorshift64*</b>. This generator has a period of 2^64
(the period defines the number of random numbers generated before the sequence begins to repeat itself).
For an overview, comparison with other random number generators, and links to articles, see
<a href=\"modelica://Modelica.Math.Random.Generators\">Math.Random.Generators</a>.
</p>
</html>",     revisions="<html>
<p>
<table border=1 cellspacing=0 cellpadding=2>
<tr><th>Date</th> <th align=\"left\">Description</th></tr>

<tr><td valign=\"top\"> June 22, 2015 </td>
    <td valign=\"top\">

<table border=0>
<tr><td valign=\"top\">
         <img src=\"modelica://Modelica/Resources/Images/Logos/dlr_logo.png\">
</td><td valign=\"bottom\">
         Initial version implemented by
         A. Kl&ouml;ckner, F. v.d. Linden, D. Zimmer, M. Otter.<br>
         <a href=\"http://www.dlr.de/rmc/sr/en\">DLR Institute of System Dynamics and Control</a>
</td></tr></table>
</td></tr>

</table>
</p>
</html>"),     Icon(coordinateSystem(preserveAspectRatio=false, extent={{-100,-100},{100,100}}),
            graphics={
        Ellipse(
          extent={{-64,0},{-14,-50}},
          lineColor={0,0,0},
          fillColor={215,215,215},
          fillPattern=FillPattern.Solid),
        Ellipse(
          extent={{12,52},{62,2}},
          lineColor={0,0,0},
          fillColor={215,215,215},
          fillPattern=FillPattern.Solid)}));
    end Xorshift64star;

    package Xorshift128plus "Random number generator xorshift128+"
      constant Integer nState=4 "The dimension of the internal state vector";

      extends Modelica.Icons.Package;

      function initialState
        "Returns an initial state for the xorshift128+ algorithm"
        input Integer localSeed
          "The local seed to be used for generating initial states";
        input Integer globalSeed
          "The global seed to be combined with the local seed";
        output Integer state[nState] "The generated initial states";
      algorithm
        state := Utilities.initialStateWithXorshift64star(
                localSeed,
                globalSeed,
                size(state, 1));
        annotation(Inline=true, Documentation(info="<html>
<h4>Syntax</h4>
<blockquote><pre>
state = Xorshift128plus.<b>initialState</b>(localSeed, globalSeed);
</pre></blockquote>

<h4>Description</h4>
<p>
Generates an initial state vector for the Xorshift128plus random number generator
(= xorshift128+ algorithm), from
two Integer numbers given as input (arguments localSeed, globalSeed). Any Integer numbers
can be given (including zero or negative number). The function returns
a reasonable initial state vector with the following strategy:
</p>

<p>
The <a href=\"modelica://Modelica.Math.Random.Generators.Xorshift64star\">Xorshift64star</a>
random number generator is used to fill the internal state vector with 64 bit random numbers.
</p>

<h4>Example</h4>
<blockquote><pre>
  <b>parameter</b> Integer localSeed;
  <b>parameter</b> Integer globalSeed;
  Integer state[Xorshift128plus.nState];
<b>initial equation</b>
  state = initialState(localSeed, globalSeed);
</pre></blockquote>

<h4>See also</h4>
<p>
<a href=\"modelica://Modelica.Math.Random.Generators.Xorshift128plus.random\">Random.Generators.Xorshift128plus.random</a>.
</p>
</html>",     revisions="<html>
<p>
<table border=1 cellspacing=0 cellpadding=2>
<tr><th>Date</th> <th align=\"left\">Description</th></tr>

<tr><td valign=\"top\"> June 22, 2015 </td>
    <td valign=\"top\">

<table border=0>
<tr><td valign=\"top\">
         <img src=\"modelica://Modelica/Resources/Images/Logos/dlr_logo.png\">
</td><td valign=\"bottom\">
         Initial version implemented by
         A. Kl&ouml;ckner, F. v.d. Linden, D. Zimmer, M. Otter.<br>
         <a href=\"http://www.dlr.de/rmc/sr/en\">DLR Institute of System Dynamics and Control</a>
</td></tr></table>
</td></tr>

</table>
</p>
</html>"));
      end initialState;

      function random
        "Returns a uniform random number with the xorshift128+ algorithm"
        extends Modelica.Icons.Function;
        input Integer stateIn[nState]
          "The internal states for the random number generator";
        output Real result
          "A random number with a uniform distribution on the interval (0,1]";
        output Integer stateOut[nState]
          "The new internal states of the random number generator";
        external "C" ModelicaRandom_xorshift128plus(stateIn, stateOut, result)
          annotation (Library="ModelicaExternalC");
        annotation (Documentation(info="<html>
<h4>Syntax</h4>
<blockquote><pre>
(r, stateOut) = Xorshift128plus.<b>random</b>(stateIn);
</pre></blockquote>

<h4>Description</h4>
<p>
Returns a uniform random number in the range 0 &lt; random &le; 1 with the xorshift128+ algorithm.
Input argument <b>stateIn</b> is the state vector of the previous call.
Output argument <b>stateOut</b> is the updated state vector.
If the function is called with identical stateIn vectors, exactly the
same random number r is returned.
</p>

<h4>Example</h4>
<blockquote><pre>
  <b>parameter</b> Integer localSeed;
  <b>parameter</b> Integer globalSeed;
  Real r;
  Integer state[Xorshift128plus.nState];
<b>initial equation</b>
  state = initialState(localSeed, globalSeed);
<b>equation</b>
  <b>when</b> sample(0,0.1) <b>then</b>
    (r, state) = random(<b>pre</b>(state));
  <b>end when</b>;
</pre></blockquote>

<h4>See also</h4>
<p>
<a href=\"modelica://Modelica.Math.Random.Generators.Xorshift128plus.initialState\">Random.Generators.Xorshift128plus.initialState</a>.
</p>
</html>",     revisions="<html>
<p>
<table border=1 cellspacing=0 cellpadding=2>
<tr><th>Date</th> <th align=\"left\">Description</th></tr>

<tr><td valign=\"top\"> June 22, 2015 </td>
    <td valign=\"top\">

<table border=0>
<tr><td valign=\"top\">
         <img src=\"modelica://Modelica/Resources/Images/Logos/dlr_logo.png\">
</td><td valign=\"bottom\">
         Initial version implemented by
         A. Kl&ouml;ckner, F. v.d. Linden, D. Zimmer, M. Otter.<br>
         <a href=\"http://www.dlr.de/rmc/sr/en\">DLR Institute of System Dynamics and Control</a>
</td></tr></table>
</td></tr>

</table>
</p>
</html>"));
      end random;
      annotation (Documentation(info="<html>
<p>
Random number generator <b>xorshift128+</b>. This generator has a period of 2^128
(the period defines the number of random numbers generated before the sequence begins to repeat itself).
For an overview, comparison with
other random number generators, and links to articles, see
<a href=\"modelica://Modelica.Math.Random.Generators\">Math.Random.Generators</a>.
</p>
</html>",     revisions="<html>
<p>
<table border=1 cellspacing=0 cellpadding=2>
<tr><th>Date</th> <th align=\"left\">Description</th></tr>

<tr><td valign=\"top\"> June 22, 2015 </td>
    <td valign=\"top\">

<table border=0>
<tr><td valign=\"top\">
         <img src=\"modelica://Modelica/Resources/Images/Logos/dlr_logo.png\">
</td><td valign=\"bottom\">
         Initial version implemented by
         A. Kl&ouml;ckner, F. v.d. Linden, D. Zimmer, M. Otter.<br>
         <a href=\"http://www.dlr.de/rmc/sr/en\">DLR Institute of System Dynamics and Control</a>
</td></tr></table>
</td></tr>

</table>
</p>
</html>"),
     Icon(graphics={
        Ellipse(
          extent={{-70,60},{-20,10}},
          lineColor={0,0,0},
          fillColor={215,215,215},
          fillPattern=FillPattern.Solid),
        Ellipse(
          extent={{32,58},{82,8}},
          lineColor={0,0,0},
          fillColor={215,215,215},
          fillPattern=FillPattern.Solid),
        Ellipse(
          extent={{-20,-12},{30,-62}},
          lineColor={0,0,0},
          fillColor={215,215,215},
          fillPattern=FillPattern.Solid)}));
    end Xorshift128plus;

    package Xorshift1024star "Random number generator xorshift1024*"
      constant Integer nState=33 "The dimension of the internal state vector";

      extends Modelica.Icons.Package;

      function initialState
        "Returns an initial state for the xorshift1024* algorithm"
        extends Modelica.Icons.Function;
        input Integer localSeed
          "The local seed to be used for generating initial states";
        input Integer globalSeed
          "The global seed to be combined with the local seed";
        output Integer state[nState] "The generated initial states";
      algorithm
        state := Utilities.initialStateWithXorshift64star(
                localSeed, globalSeed, size(state, 1));
        annotation(Inline=true, Documentation(info="<html>
<h4>Syntax</h4>
<blockquote><pre>
state = Xorshift1024star.<b>initialState</b>(localSeed, globalSeed);
</pre></blockquote>

<h4>Description</h4>

<p>
Generates an initial state vector for the Xorshift1024star random number generator
(= xorshift1024* algorithm), from
two Integer numbers given as input (arguments localSeed, globalSeed). Any Integer numbers
can be given (including zero or negative number). The function returns
a reasonable initial state vector with the following strategy:
</p>

<p>
The <a href=\"modelica://Modelica.Math.Random.Generators.Xorshift64star\">Xorshift64star</a>
random number generator is used to fill the internal state vector with 64 bit random numbers.
</p>

<h4>Example</h4>
<blockquote><pre>
  <b>parameter</b> Integer localSeed;
  <b>parameter</b> Integer globalSeed;
  Integer state[Xorshift1024star.nState];
<b>initial equation</b>
  state = initialState(localSeed, globalSeed);
</pre></blockquote>

<h4>See also</h4>
<p>
<a href=\"modelica://Modelica.Math.Random.Generators.Xorshift1024star.random\">Random.Generators.Xorshift1024star.random</a>.
</p>
</html>",     revisions="<html>
<p>
<table border=1 cellspacing=0 cellpadding=2>
<tr><th>Date</th> <th align=\"left\">Description</th></tr>

<tr><td valign=\"top\"> June 22, 2015 </td>
    <td valign=\"top\">

<table border=0>
<tr><td valign=\"top\">
         <img src=\"modelica://Modelica/Resources/Images/Logos/dlr_logo.png\">
</td><td valign=\"bottom\">
         Initial version implemented by
         A. Kl&ouml;ckner, F. v.d. Linden, D. Zimmer, M. Otter.<br>
         <a href=\"http://www.dlr.de/rmc/sr/en\">DLR Institute of System Dynamics and Control</a>
</td></tr></table>
</td></tr>

</table>
</p>
</html>"));
      end initialState;

      function random
        "Returns a uniform random number with the xorshift1024* algorithm"
        extends Modelica.Icons.Function;
        input Integer stateIn[nState]
          "The internal states for the random number generator";
        output Real result
          "A random number with a uniform distribution on the interval (0,1]";
        output Integer stateOut[nState]
          "The new internal states of the random number generator";
        external "C" ModelicaRandom_xorshift1024star(stateIn, stateOut, result)
          annotation (Library="ModelicaExternalC");
        annotation (Documentation(info="<html>
<h4>Syntax</h4>
<blockquote><pre>
(r, stateOut) = Xorshift128plus.<b>random</b>(stateIn);
</pre></blockquote>

<h4>Description</h4>
<p>
Returns a uniform random number in the range 0 &lt; random &le; 1 with the xorshift1024* algorithm.
Input argument <b>stateIn</b> is the state vector of the previous call.
Output argument <b>stateOut</b> is the updated state vector.
If the function is called with identical stateIn vectors, exactly the
same random number r is returned.
</p>

<h4>Example</h4>
<blockquote><pre>
  <b>parameter</b> Integer localSeed;
  <b>parameter</b> Integer globalSeed;
  Real r;
  Integer state[Xorshift1024star.nState];
<b>initial equation</b>
  state = initialState(localSeed, globalSeed);
<b>equation</b>
  <b>when</b> sample(0,0.1) <b>then</b>
    (r, state) = random(<b>pre</b>(state));
  <b>end when</b>;
</pre></blockquote>

<h4>See also</h4>
<p>
<a href=\"modelica://Modelica.Math.Random.Generators.Xorshift1024star.initialState\">Random.Generators.Xorshift1024star.initialState</a>.
</p>
</html>",     revisions="<html>
<p>
<table border=1 cellspacing=0 cellpadding=2>
<tr><th>Date</th> <th align=\"left\">Description</th></tr>

<tr><td valign=\"top\"> June 22, 2015 </td>
    <td valign=\"top\">

<table border=0>
<tr><td valign=\"top\">
         <img src=\"modelica://Modelica/Resources/Images/Logos/dlr_logo.png\">
</td><td valign=\"bottom\">
         Initial version implemented by
         A. Kl&ouml;ckner, F. v.d. Linden, D. Zimmer, M. Otter.<br>
         <a href=\"http://www.dlr.de/rmc/sr/en\">DLR Institute of System Dynamics and Control</a>
</td></tr></table>
</td></tr>

</table>
</p>
</html>"));
      end random;
      annotation (Documentation(info="<html>
<p>
Random number generator <b>xorshift1024*</b>. This generator has a period of 2^1024
(the period defines the number of random numbers generated before the sequence begins to repeat itself).
For an overview, comparison with other random number generators, and links to articles, see
<a href=\"modelica://Modelica.Math.Random.Generators\">Math.Random.Generators</a>.
</p>
</html>",     revisions="<html>
<p>
<table border=1 cellspacing=0 cellpadding=2>
<tr><th>Date</th> <th align=\"left\">Description</th></tr>

<tr><td valign=\"top\"> June 22, 2015 </td>
    <td valign=\"top\">

<table border=0>
<tr><td valign=\"top\">
         <img src=\"modelica://Modelica/Resources/Images/Logos/dlr_logo.png\">
</td><td valign=\"bottom\">
         Initial version implemented by
         A. Kl&ouml;ckner, F. v.d. Linden, D. Zimmer, M. Otter.<br>
         <a href=\"http://www.dlr.de/rmc/sr/en\">DLR Institute of System Dynamics and Control</a>
</td></tr></table>
</td></tr>

</table>
</p>
</html>"),
     Icon(graphics={
        Ellipse(
          extent={{-70,78},{-20,28}},
          lineColor={0,0,0},
          fillColor={215,215,215},
          fillPattern=FillPattern.Solid),
        Ellipse(
          extent={{20,58},{70,8}},
          lineColor={0,0,0},
          fillColor={215,215,215},
          fillPattern=FillPattern.Solid),
        Ellipse(
          extent={{-64,6},{-14,-44}},
          lineColor={0,0,0},
          fillColor={215,215,215},
          fillPattern=FillPattern.Solid),
        Ellipse(
          extent={{16,-20},{66,-70}},
          lineColor={0,0,0},
          fillColor={215,215,215},
          fillPattern=FillPattern.Solid)}));
    end Xorshift1024star;
    annotation (Icon(coordinateSystem(preserveAspectRatio=false, extent={{
          -100,-100},{100,100}}), graphics={Line(
        points={{-90,-54},{-50,-54},{-50,54},{50,54},{50,-54},{84,-54}})}), Documentation(info="<html>
<p>
This package contains various pseudo random number generators. A random number generator is a package
that consists of the following elements:
</p>
<ul>
<li> Integer <b>nState</b> is a constant that defines the length of the internal state vector
     (in order that an appropriate Integer vector of this length can be declared, depending on
     the selected random number generator).</li>
<li> Function <b>initialState(..)</b> is used to initialize the state of the random number generator
     by providing Integer seeds and calling the random number generator often enough that
     statistically relevant random numbers are returned by every call of function random(..).</li>
<li> Function <b>random(..)</b> is used to return a random number of type Real in the range
     0.0 &lt; random &le; 1.0 for every call.
     Furthermore, the updated (internal) state of the random number generator is returned as well.
    </li>
</ul>

<p>
In order to have consistent interfaces, the function explained above should be extended from the Interfaces provided in
package <a href=\"Interfaces\">Interfaces</a>.
</p>

<p>
The Generators package contains the <b>xorshift</b> suite of random number generators
from Sebastiano Vigna (from 2014; based on work of George Marsaglia).
The properties of these random
number generators are summarized below and compared with the often used
Mersenne Twister (MT19937-64) generator. The table is based on
<a href=\"http://xorshift.di.unimi.it/\">http://xorshift.di.unimi.it/</a> and on the
articles:
</p>
<blockquote>
<p>
Sebastiano Vigna:
<a href=\"http://vigna.di.unimi.it/ftp/papers/xorshift.pdf\">An experimental exploration of Marsaglia's xorshift generators, scrambled</a>, 2014.<br>
Sebastiano Vigna:
<a href=\"http://vigna.di.unimi.it/ftp/papers/xorshiftplus.pdf\">Further scramblings of Marsaglia's xorshift generators</a>, 2014.<br>
</p>
</blockquote>

<p>
Summary of the properties of the random number generators:
</p>

<p>

</p>

<blockquote>
<p>
<table border=1 cellspacing=0 cellpadding=2>
<tr><th>Property</th>
    <th>xorshift64*</th>
    <th>xorshift128+</th>
    <th>xorshift1024*</th>
    <th>MT19937-64</th></tr>

<tr><td>Period</td>
    <td>2^64</td>
    <td>2^128</td>
    <td>2^1024</td>
    <td>2^19937</td></tr>

<tr><td>Length of state (# 32 bit integer)</td>
    <td>2</td>
    <td>4</td>
    <td>33</td>
    <td>624</td></tr>

<tr><td>Statistic failures (Big Crush)</td>
    <td>363</td>
    <td>64</td>
    <td>51</td>
    <td>516</td></tr>

<tr><td>Systematic failures (Big Crush)</td>
    <td>yes</td>
    <td>no</td>
    <td>no</td>
    <td>yes</td></tr>

<tr><td>Worst case startup</td>
    <td> &gt; 1 call       </td>
    <td> &gt; 20 calls     </td>
    <td> &gt; 100 calls    </td>
    <td> &gt; 100000 calls </td></tr>

<tr><td>Run time (MT=1.0)</td>
    <td> 0.39 </td>
    <td> 0.27 </td>
    <td> 0.33 </td>
    <td> 1.0  </td></tr>
</table>
</p>
</blockquote>

<p>
Further explanations of the properties above:
</p>

<ul>
<li> The <b>period</b> defines the number of random numbers generated
     before the sequence begins to repeat itself. According to
     \"<a href=\"http://xorshift.di.unimi.it/\">A long period does not imply high quality</a>\"
     a period of 2^1024 is by far large enough for even massively parallel simulations
     with huge number of random number computations per simulation.
     A period of 2^128 might be not enough for massively parallel simulations.
     </li>

<li> <b>Length of state (# 32 bit integer)</b> defines the number of \"int\" (that is Modelica Integer) elements
     used for the internal state vector.</li>

<li> <b>Big Crush</b> is part of <a href=\"http://simul.iro.umontreal.ca/testu01/tu01.html\">TestU01</a>
     a huge framework for testing random number generators.
     According to these tests, the statistical properties of the xorshift random number
     generators are better than the ones of the Mersenne Twister random number generator.</li>

<li> <b>Worst case startup</b> means how many calls are needed until getting
     from a bad seed to random numbers with appropriate statistical properties.
     Here, the xorshift random number suite has much better properties
     than the Mersenne Twister. When initializing a random number generator, the above property
     is taken into account and appropriate random numbers are generated, so that a subsequent
     call of random(..) will generate statistically relevant random numbers, even if the user
     provides a bad initial seed (such as localSeed=1). This means, any Integer number can be given as
     initial seed without influencing the quality of the generated random numbers.</li>

<li> <b>Run time</b> shows that the xorshift random number generators are
     all much faster than the Mersenne Twister random number generator, although
     this is not really relevant for most simulations, because the execution
     time of the other parts of the simulations is usually much larger. </li>
</ul>

<p>
The xorshift random number generators are used in the following way in the
<a href=\"Modelica.Blocks.Noise\">Blocks.Noise</a> package:
</p>
<ol>
<li> Xorshift64star (xorshift64*) is used to generate the initial internal state vectors of the
     other generators from two Integer values, due
     to the very good startup properties.</li>

<li> Xorshift128plus (xorshift128+) is the default random number generator
     used by the blocks in <a href=\"Modelica.Blocks.Noise\">Blocks.Noise</a>.
     Since these blocks hold the internal state vector for every block instance, and the
     internal state vector is copied whenever a new random number is drawn, it is important
     that the internal state vector is short (and still has good statistical properties
     as shown in the table above).</li>

<li> Xorshift1024star (xorshift1024*) is the basis of the impure function
     <a href=\"Modelica.Math.Random.Utilities.impureRandom\">Math.Random.Utilities.impureRandom</a>
     which in turn is used with
     <a href=\"modelica://Modelica.Blocks.Noise.GlobalSeed.random\">Blocks.Noise.GlobalSeed.random</a>.
     The internal state vector is not exposed. It is updated internally, whenever a new random number
     is drawn.</li>
</ol>

<p>
Note, the generators produce 64 bit random numbers.
These numbers are mapped to the 52 bit mantissa of double numbers in the range 0.0 .. 1.0.
</p>
</html>",   revisions="<html>
<p>
<table border=1 cellspacing=0 cellpadding=2>
<tr><th>Date</th> <th align=\"left\">Description</th></tr>

<tr><td valign=\"top\"> June 22, 2015 </td>
    <td valign=\"top\">

<table border=0>
<tr><td valign=\"top\">
         <img src=\"modelica://Modelica/Resources/Images/Logos/dlr_logo.png\">
</td><td valign=\"bottom\">
         Initial version implemented by
         A. Kl&ouml;ckner, F. v.d. Linden, D. Zimmer, M. Otter.<br>
         <a href=\"http://www.dlr.de/rmc/sr/en\">DLR Institute of System Dynamics and Control</a>
</td></tr></table>
</td></tr>

</table>
</p>
</html>"));
  end Generators;

  package Utilities
    "Library of utility functions for the Random package (usually of no interest for the user)"

    extends Modelica.Icons.UtilitiesPackage;

    function initialStateWithXorshift64star
      "Return an initial state vector for a random number generator (based on xorshift64star algorithm)"
      import Modelica.Math.Random.Generators.Xorshift64star;
      extends Modelica.Icons.Function;
      input Integer localSeed
        "The local seed to be used for generating initial states";
      input Integer globalSeed
        "The global seed to be combined with the local seed";
      input Integer nState(min=1) "The dimension of the state vector (>= 1)";
      output Integer[nState] state "The generated initial states";

    protected
      Real r "Random number only used inside function";
      Integer aux[2] "Intermediate container of state integers";
      Integer nStateEven "Highest even number <= nState";
    algorithm
      // Set the first 2 states by using the initialState() function
      aux            := Xorshift64star.initialState(localSeed, globalSeed);
      if nState >= 2 then
        state[1:2]   := aux;
      else
        state[1]     := aux[1];
      end if;

      // Fill the next elements of the state vector
      nStateEven     := 2*div(nState, 2);
      for i in 3:2:nStateEven loop
        (r,aux)      := Xorshift64star.random(state[i-2:i-1]);
        state[i:i+1] := aux;
      end for;

      // If nState is uneven, fill the last element as well
      if nState >= 3 and nState <> nStateEven then
        (r,aux)       := Xorshift64star.random(state[nState-2:nState-1]);
        state[nState] := aux[1];
      end if;

      annotation (Documentation(revisions="<html>
<p>
<table border=1 cellspacing=0 cellpadding=2>
<tr><th>Date</th> <th align=\"left\">Description</th></tr>

<tr><td valign=\"top\"> June 22, 2015 </td>
    <td valign=\"top\">

<table border=0>
<tr><td valign=\"top\">
         <img src=\"modelica://Modelica/Resources/Images/Logos/dlr_logo.png\">
</td><td valign=\"bottom\">
         Initial version implemented by
         A. Kl&ouml;ckner, F. v.d. Linden, D. Zimmer, M. Otter.<br>
         <a href=\"http://www.dlr.de/rmc/sr/en\">DLR Institute of System Dynamics and Control</a>
</td></tr></table>
</td></tr>

</table>
</p>
</html>",     info="<html>
<h4>Syntax</h4>
<blockquote><pre>
state = Utilities.<b>initialStateWithXorshift6star</b>(localSeed, globalSeed, nState);
</pre></blockquote>

<h4>Description</h4>

<p>
The <a href=\"modelica://Modelica.Math.Random.Generators.Xorshift64star\">Xorshift64star</a>
random number generator is used to fill a state vector of length nState (nState &ge; 1) with random numbers and return
this vector. Arguments localSeed and globalSeed are any Integer numbers (including zero or negative number)
that characterize the initial state.
If the same localSeed, globalSeed, nState is given, the same state vector is returned.
</p>

<h4>Example</h4>
<blockquote><pre>
  parameter Integer localSeed;
  parameter Integer globalSeed;
  Integer state[33];
<b>initial equation</b>
  state = Utilities.initialStateWithXorshift64star(localSeed, globalSeed, size(state,1));
</pre></blockquote>
</html>"));
    end initialStateWithXorshift64star;

    function automaticGlobalSeed
      "Creates an automatic integer seed (typically from the current time and process id; this is an impure function)"
      input Real dummy
        "Dummy variable to force evaluation at run-time; use 'time' as input argument";
      output Integer seed "Automatically generated seed";

      external "C" seed = ModelicaRandom_automaticGlobalSeed(dummy) annotation (Library="ModelicaExternalC");

     annotation (Documentation(info="<html>
<h4>Syntax</h4>
<blockquote><pre>
seed = Utilities.<b>automaticGlobalSeed</b>(dummy);
</pre></blockquote>

<h4>Description</h4>
<p>Returns an automatically computed seed (Integer). Typically, this seed is computed from:</p>
<ol>
<li> The current localtime by computing the number of milli-seconds up to the current hour</li>
<li> The process id (added to the first part by multiplying it with the prime number 6007).</li>
</ol>
<p>
If getTime and getPid functions are not available on the target where this Modelica function
is called, other means to compute a seed may be used.
</p>

<p>
Note, this is an impure function that returns always a different value, when it is newly called.
This function should be only called once during initialization.
In order that tools are not able to optimize this (impure) function away, a dummy
argument is provided. Pass \"time\" in this argument.
</p>

<h4>Example</h4>
<pre>
     <b>parameter</b> Boolean useAutomaticSeed = false;
     <b>parameter</b> Integer fixedSeed = 67867967;
     <b>final parameter</b> Integer seed(fixed = false);
  <b>initial equation</b>
     seed = <b>if</b> useAutomaticSeed <b>then</b>
                 Random.Utilities.automaticGlobalSeed(time)
            <b>else</b> 
                 fixedSeed;
</pre>

<h4>See also</h4>
<p>
<a href=\"modelica://Modelica_Noise.Math.Random.Utilities.automaticLocalSeed\">automaticLocalSeed</a>.
</p>
<h4>Note</h4>
<p>This function is impure!</p>
</html>",     revisions="<html>
<p>
<table border=1 cellspacing=0 cellpadding=2>
<tr><th>Date</th> <th align=\"left\">Description</th></tr>

<tr><td valign=\"top\"> June 22, 2015 </td>
    <td valign=\"top\">

<table border=0>
<tr><td valign=\"top\">
         <img src=\"modelica://Modelica_Noise/Resources/Images/Blocks/Noise/dlr_logo.png\">
</td><td valign=\"bottom\">
         Initial version implemented by
         A. Kl&ouml;ckner, F. v.d. Linden, D. Zimmer, M. Otter.<br>
         <a href=\"http://www.dlr.de/rmc/sr/en\">DLR Institute of System Dynamics and Control</a>
</td></tr></table>
</td></tr>

</table>
</p>
</html>"));
    end automaticGlobalSeed;

    function automaticLocalSeed
      "Creates an automatic local seed from the instance name"
      input String path
        "Full path name of the instance (inquire with getInstanceName())";
      output Integer seed "Automatically generated seed";
    protected
      Integer pos;
      Integer len;
      String str;
    algorithm
      // Remove first name from the path, because all instances have the same root name
      pos := Modelica.Utilities.Strings.find(path, ".");
      len := Modelica.Utilities.Strings.length(path);
      if pos > 0 and pos < len then
        str := Modelica.Utilities.Strings.substring(path, pos+1, len);
      else
        str := path;
      end if;

      // Generate a hash value from the generated string
      seed := Modelica.Utilities.Strings.hashString(str);

     annotation (Documentation(info="<html>
<h4>Syntax</h4>
<blockquote><pre>
seed = Utilities.<b>automaticLocalSeed</b>(path);
</pre></blockquote>

<h4>Description</h4>
<p>
Returns an automatically computed seed (Integer) from the hash value of
the full path name of an instance (has to be inquired in the model or block
where this function is called by getInstanceName()). Contrary to automaticGlobalSeed(),
this is a pure function, that is, the same seed is returned, if an identical
path is provided.
</p>

<h4>Example</h4>
<blockquote><pre>
<b>parameter</b> Boolean useAutomaticLocalSeed = true;
<b>parameter</b> Integer fixedLocalSeed        = 10;
<b>final parameter</b> Integer localSeed = <b>if</b> useAutomaticLocalSeed <b>then</b>
                                       automaticLocalSeed(getInstanceName())
                                    <b>else</b>
                                       fixedLocalSeed;
</pre></blockquote>

<h4>See also</h4>
<p>
<a href=\"modelica://Modelica.Math.Random.Utilities.automaticGlobalSeed\">automaticGlobalSeed</a>.
</p>
</html>",     revisions="<html>
<p>
<table border=1 cellspacing=0 cellpadding=2>
<tr><th>Date</th> <th align=\"left\">Description</th></tr>

<tr><td valign=\"top\"> June 22, 2015 </td>
    <td valign=\"top\">

<table border=0>
<tr><td valign=\"top\">
         <img src=\"modelica://Modelica/Resources/Images/Logos/dlr_logo.png\">
</td><td valign=\"bottom\">
         Initial version implemented by
         A. Kl&ouml;ckner, F. v.d. Linden, D. Zimmer, M. Otter.<br>
         <a href=\"http://www.dlr.de/rmc/sr/en\">DLR Institute of System Dynamics and Control</a>
</td></tr></table>
</td></tr>

</table>
</p>
</html>"));
    end automaticLocalSeed;

    function initializeImpureRandom
      "Initializes the internal state of the impure random number generator"
      input Integer seed
        "The input seed to initialize the impure random number generator";
      input Real dummy
        "Dummy variable to force evaluation at run-time; use 'time' as input argument";
      output Integer id
        "Identification number to be passed as input to function impureRandom, in order that sorting is correct";
    protected
      constant Integer localSeed = 715827883
        "Since there is no local seed, a large prime number is used";
      Integer iDummy = integer(dummy);
      Integer localSeed2 = if iDummy == 1 then iDummy*localSeed else localSeed;
      Integer rngState[33]
        "The internal state vector of the impure random number generator";

      function setInternalState
        "Stores the given state vector in an external static variable"
        input Integer[33] rngState "The initial state";
        input Integer id;
        external "C" ModelicaRandom_setInternalState_xorshift1024star(rngState, size(rngState,1), id)
          annotation (Library="ModelicaExternalC");
      end setInternalState;

    algorithm
      // Determine the internal state (several iterations with a generator that quickly generates good numbers
      rngState := initialStateWithXorshift64star(localSeed2, seed, size(rngState, 1));
      id :=localSeed2;

      // Copy the internal state into the internal C static memory
      setInternalState(rngState, id);
      annotation (Documentation(info="<html>
<h4>Syntax</h4>
<blockquote><pre>
id = <b>initializeImpureRandom</b>(seed, dummy);
</pre></blockquote>

<h4>Description</h4>

<p>
Generates a hidden initial state vector for the
<a href=\"modelica://Modelica.Math.Random.Generators.Xorshift1024star\">Xorshift1024star</a>
random number generator (= xorshift1024* algorithm), from Integer input argument seed. Argument seed
can be given any value (including zero or negative number). The function returns the
dummy Integer number id. This number needs to be passed as input to function
<a href=\"modelica://Modelica.Math.Random.Utilities.impureRandom\">impureRandom</a>,
in order that the sorting order is correct (so that impureRandom is always called
after initializeImpureRandom). The function stores a reasonable initial state vector
in a C-static memory by using the
<a href=\"modelica://Modelica.Math.Random.Generators.Xorshift64star\">Xorshift64star</a>
random number generator to fill the internal state vector with 64 bit random numbers.
</p>

<h4>Example</h4>
<blockquote><pre>
  <b>parameter</b> Integer seed;
  Real r;
  <b>function</b> random = impureRandom (<b>final</b> id=id);
<b>protected </b>
  Integer id;
<b>equation</b>
  // Initialize the random number generator
  <b>when</b> initial() <b>then</b>
    id = initializeImpureRandom(seed, time);
  <b>end when</b>;

  // Use the random number generator
  <b>when</b> sample(0,0.001) <b>then</b>
     r = random();
  <b>end when</b>;
</pre></blockquote>

<h4>See also</h4>
<p>
<a href=\"modelica://Modelica.Math.Random.Utilities.impureRandom\">Utilities.impureRandom</a>,
<a href=\"modelica://Modelica.Math.Random.Generators\">Random.Generators</a>
</p>
</html>",     revisions="<html>
<p>
<table border=1 cellspacing=0 cellpadding=2>
<tr><th>Date</th> <th align=\"left\">Description</th></tr>

<tr><td valign=\"top\"> June 22, 2015 </td>
    <td valign=\"top\">

<table border=0>
<tr><td valign=\"top\">
         <img src=\"modelica://Modelica/Resources/Images/Logos/dlr_logo.png\">
</td><td valign=\"bottom\">
         Initial version implemented by
         A. Kl&ouml;ckner, F. v.d. Linden, D. Zimmer, M. Otter.<br>
         <a href=\"http://www.dlr.de/rmc/sr/en\">DLR Institute of System Dynamics and Control</a>
</td></tr></table>
</td></tr>

</table>
</p>
</html>"));
    end initializeImpureRandom;

    function impureRandom
      "Impure random number generator (with hidden state vector)"
      input Integer id
        "Identification number from initializeImpureRandom(..) function (is needed for correct sorting)";
      output Real y
        "A random number with a uniform distribution on the interval (0,1]";
      external "C" y = ModelicaRandom_impureRandom_xorshift1024star(id)
        annotation (Library="ModelicaExternalC");
      annotation(Documentation(info="<html>
<h4>Syntax</h4>
<blockquote><pre>
r = <b>impureRandom</b>(id);
</pre></blockquote>

<h4>Description</h4>
<p>
Returns a uniform random number in the range 0 &lt; random &le; 1 with the xorshift1024* algorithm.
The dummy input Integer argument id must be the output argument of a call to function
<a href=\"modelica://Modelica.Math.Random.Utilities.initializeImpureRandom\">initializeImpureRandom</a>,
in order that the sorting order is correct (so that impureRandom is always called
after initializeImpureRandom). For every call of impureRandom(id), a different random number
is returned, so the function is impure.
</p>

<h4>Example</h4>
<blockquote><pre>
  <b>parameter</b> Integer seed;
  Real r;
  <b>function</b> random = impureRandom (<b>final</b> id=id);
<b>protected </b>
  Integer id;
<b>equation</b>
  // Initialize the random number generator
  <b>when</b> initial() <b>then</b>
    id = initializeImpureRandom(seed, time);
  <b>end when</b>;

  // Use the random number generator
  <b>when</b> sample(0,0.001) <b>then</b>
     r = random();
  <b>end when</b>;
</pre></blockquote>

<h4>See also</h4>
<p>
<a href=\"modelica://Modelica.Math.Random.Utilities.initializeImpureRandom\">initializeImpureRandom</a>,
<a href=\"modelica://Modelica.Math.Random.Generators\">Random.Generators</a>
</p>
<h4>Note</h4>
<p>This function is impure!</p>
</html>",     revisions="<html>
<p>
<table border=1 cellspacing=0 cellpadding=2>
<tr><th>Date</th> <th align=\"left\">Description</th></tr>

<tr><td valign=\"top\"> June 22, 2015 </td>
    <td valign=\"top\">

<table border=0>
<tr><td valign=\"top\">
         <img src=\"modelica://Modelica/Resources/Images/Logos/dlr_logo.png\">
</td><td valign=\"bottom\">
         Initial version implemented by
         A. Kl&ouml;ckner, F. v.d. Linden, D. Zimmer, M. Otter.<br>
         <a href=\"http://www.dlr.de/rmc/sr/en\">DLR Institute of System Dynamics and Control</a>
</td></tr></table>
</td></tr>

</table>
</p>
</html>"));
    end impureRandom;

    function impureRandomInteger
      "Impure random number generator for integer values (with hidden state vector)"
      input Integer id
        "Identification number from initializeImpureRandom(..) function (is needed for correct sorting)";
      input Integer imin = 1 "Minimum integer to generate";
      input Integer imax = Modelica.Constants.Integer_inf
        "Maximum integer to generate";
      output Integer y
        "A random number with a uniform distribution on the interval [imin,imax]";
    protected
      Real r "Impure Real random number";
    algorithm
      r  := impureRandom(id=id);
      y  := integer(r*imax) + integer((1-r)*imin);
      y  := min(imax, max(imin, y));

      annotation (Documentation(info="<html>
<h4>Syntax</h4>
<blockquote><pre>
r = <b>impureRandomInteger</b>(id, imin=1, imax=Modelica.Constants.Integer_inf);
</pre></blockquote>

<h4>Description</h4>
<p>
Returns an Integer random number in the range imin &le; random &le; imax with the xorshift1024* algorithm,
(the random number in the range 0 ... 1 returned by the xorshift1024* algorithm is mapped to
an Integer number in the range imin ... imax).
The dummy input Integer argument id must be the output argument of a call to function
<a href=\"modelica://Modelica.Math.Random.Utilities.initializeImpureRandom\">initializeImpureRandom</a>,
in order that the sorting order is correct (so that impureRandomInteger is always called
after initializeImpureRandom). For every call of impureRandomInteger(id), a different random number
is returned, so the function is impure.
</p>

<h4>See also</h4>
<p>
<a href=\"modelica://Modelica.Math.Random.Utilities.initializeImpureRandom\">initializeImpureRandom</a>,
<a href=\"modelica://Modelica.Math.Random.Generators\">Random.Generators</a>
</p>
<h4>Note</h4>
<p>This function is impure!</p>
</html>"));
    end impureRandomInteger;
  annotation (Documentation(info="<html>
<p>
This package contains utility functions for the random number generators,
that are usually of no interest for the user
(they are, for example, used in package <a href=\"modelica://Modelica.Blocks.Noise\">Blocks.Noise</a>).
</p>
</html>",   revisions="<html>
<p>
<table border=1 cellspacing=0 cellpadding=2>
<tr><th>Date</th> <th align=\"left\">Description</th></tr>

<tr><td valign=\"top\"> June 22, 2015 </td>
    <td valign=\"top\">

<table border=0>
<tr><td valign=\"top\">
         <img src=\"modelica://Modelica/Resources/Images/Logos/dlr_logo.png\">
</td><td valign=\"bottom\">
         Initial version implemented by
         A. Kl&ouml;ckner, F. v.d. Linden, D. Zimmer, M. Otter.<br>
         <a href=\"http://www.dlr.de/rmc/sr/en\">DLR Institute of System Dynamics and Control</a>
</td></tr></table>
</td></tr>

</table>
</p>
</html>"));
  end Utilities;
  annotation (Icon(coordinateSystem(preserveAspectRatio=false, extent={{-100,
        -100},{100,100}}), graphics={
    Ellipse(
      extent={{-84,84},{-24,24}},
      lineColor={0,0,0},
      fillColor={215,215,215},
      fillPattern=FillPattern.Solid),
    Ellipse(
      extent={{22,62},{82,2}},
      lineColor={0,0,0},
      fillColor={215,215,215},
      fillPattern=FillPattern.Solid),
    Ellipse(
      extent={{-58,6},{2,-54}},
      lineColor={0,0,0},
      fillColor={215,215,215},
      fillPattern=FillPattern.Solid),
    Ellipse(
      extent={{26,-30},{86,-90}},
      lineColor={0,0,0},
      fillColor={215,215,215},
      fillPattern=FillPattern.Solid)}), Documentation(info="<html>
<p>
This package contains low level functions for the generation of random numbers.
Usually, the functions in this package are not used directly, but are utilized
as building blocks of higher level functionality.
</p>

<p>
Package <a href=\"modelica://Modelica.Math.Random.Generators\">Math.Random.Generators</a>
contains various pseudo random number generators. These generators are used in the blocks
of package <a href=\"modelica://Modelica.Blocks.Noise\">Blocks.Noise</a> to generate
reproducible noise signals.
Package <a href=\"modelica://Modelica.Math.Random.Utilities\">Math.Random.Utilities</a>
contains utility functions for the random number generators,
that are usually of no interest for the user
(they are, for example, used to implement the blocks in
package <a href=\"modelica://Modelica.Blocks.Noise\">Blocks.Noise</a>).
</p>
</html>", revisions="<html>
<p>
<table border=1 cellspacing=0 cellpadding=2>
<tr><th>Date</th> <th align=\"left\">Description</th></tr>

<tr><td valign=\"top\"> June 22, 2015 </td>
    <td valign=\"top\">

<table border=0>
<tr><td valign=\"top\">
         <img src=\"modelica://Modelica/Resources/Images/Logos/dlr_logo.png\">
</td><td valign=\"bottom\">
         Initial version implemented by
         A. Kl&ouml;ckner, F. v.d. Linden, D. Zimmer, M. Otter.<br>
         <a href=\"http://www.dlr.de/rmc/sr/en\">DLR Institute of System Dynamics and Control</a>
</td></tr></table>
</td></tr>

</table>
</p>
</html>"));
end Random;