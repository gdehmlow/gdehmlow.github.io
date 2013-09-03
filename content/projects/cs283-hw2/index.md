---
title: Monte Carlo Pathtracer
created_at: 02/03/2013
kind: project
description: A Monte Carlo pathtracer written in C++
tags:
  - graphics
  - c++
---

<style>
  .compareContrast a {
    display:block; width: 500px; height:500px; background-image: url('./directLighting.jpg');
  }

  .compareContrast a:hover {
    background-image: url('./totalLighting.jpg');
  }

  .mblurCompare a {
    display:block; width: 500px; height:500px; background-image: url('./mblur1.jpg');
  }

  .mblurCompare a:hover {
    background-image: url('./mblur2.jpg');
  }
</style>

<div class="row">
<div class="nine columns">
  <img src="./cornellBox1.jpg" title="Showing off my pathtracer" />
</div>
<div class="three columns">
  <p style="line-height: 1.3em; margin-bottom: 10px;"><strong>Samples per pixel:</strong><br> 100</p>
  <p style="line-height: 1.3em; margin-bottom: 10px;"><strong>Time to render:</strong><br>~600s</p>
</div>
</div>

#### Source code

View on Github [here](https://github.com/gdehmlow/cs283-hw2) and click [here](https://github.com/gdehmlow/cs283-hw2/archive/master.zip) to download. 

#### Purpose

The goal of the pathtracer project was to extend my raytracing project from cs184 to include support for diffuse and specular interreflections as well as direct, reflective, and transmissive lighting, which produces more realistic and physically based renders. For example, in the image above, we see the red color of the wall is bleeding onto the diffuse sphere as well as some white being reflected from the ground.

<hr>

<div class="row">
<div class="nine columns">
  <img src="./cornellBox1k.jpg" />
</div>
<div class="three columns">
  <p style="line-height: 1.3em; margin-bottom: 10px;"><strong>Samples per pixel:</strong><br> 1000</p>
  <p style="line-height: 1.3em; margin-bottom: 10px;"><strong>Time to render:</strong><br>5836s</p>
</div>
</div>

<hr>

#### Pixel sampling

Since we're using Monte Carlo integration to render the scene, instead of shooting one ray per pixel, we're shooting however many it takes for the scene to converge to a reasonable noise level (or more accurately, however many rays our patience can handle). I chose to shoot the rays randomly through their respective pixels, which helps with anti-aliasing.


#### Illumination

When the ray we shoot into the scene intersects a diffuse or glossy object, it "bounces" and generates another ray in a random direction. If we were to shoot infinity rays in the scene randomly, we would simulate all of the light paths. 

Anyway, we need to account for the light at the surface for the current intersection, so we get the direct lighting at that point add that to our running color total. Important to note is that each ray has a weight (initially 1), and each successive bounce lowers that weight proportional to the reflectance of the surface material, which in turn lowers the contribution from the direct lighting at each successive point.

<hr>

<div class="row">
<div class="nine columns compareContrast">
  <a></a>
</div>
<div class="three columns">
  <p><strong>Hover over the image</strong> to turn on indirect lighting.</p>

  <p style="line-height: 1.3em; margin-bottom: 10px;"><strong>Samples per pixel:</strong><br> 10</p>
  <p style="line-height: 1.3em; margin-bottom: 10px;"><strong>Time to render:</strong><br>~60s (with indirect) <br>~3s (without indirect)</p>
</div>
</div>

<hr>

#### Area Lights

Since I'm shooting a bunch of rays through the same pixel, to handle area lights, all I did was shoot one ray (instead of many and averaging) randomly toward the light source to get its contribution at each intersection. This produces nice area lights when the number of samples per pixel gets higher (>100) and it keeps things from slowing down too much.

#### Importance Sampling

<img style="margin: 10px; float: right;" src="./specularLobe.jpg" title="Visualizing the distribution of rays on a glossy surface" />

If we wanted to, for every surface, we could generate a random ray on the hemisphere oriented to the tangent of the intersection and that would work fine, especially for diffuse surfaces. But we know that for glossy surfaces, most of the energy at each intersection point comes from lobe oriented to the perfect reflected direction of light, so it would make sense to sample that area more highly. Since we're using lambertian and phong brdfs, we sample accordingly. Jason Lawrence has a great writeup of it <a href="http://www.cs.virginia.edu/~jdl/importance.doc">here</a> (.doc). Thanks to a bug in my program at one point, I was able to verify it was working correctly (right).

For glossy surfaces we actually have to sample both specular and diffuse components of the brdf, so for each indirect ray per intersection we choose either to sample the cosine weighted hemisphere or the specular lobe with probability proportional to whichever one is bigger, and we weight each accordingly.

#### Russian Roulette

After a few bounces, the indirect lighting starts to contribute a lot less to the total energy at a given intersection. But we can't just cut the ray off, as that introduces bias. To get around this, we say that after the weight of the ray falls below a certain point, we will kill the ray with a certain probability p and weight the survivors by 1 / p. For the image above, p = .2 -> 74s, p = .5 -> 64s, and p = .01 -> 60s.

#### Motion Blur

For my multidimensional integration, I chose to do motion blur. It was simple to implement: as we take more samples per pixel, we increment time t uniformly such that it starts at 0 and is 1 when we take our last sample for a pixel. When calculating the intersections with objects, t is passed along to determine the location of the object at that time. The sphere runs on a constant velocity path between two points.

The nice thing about this scheme is that it really adds nothing to cost of computation. The ugly thing is what can be seen below: if you don't take that many samples, you can actually see a snapshot of the ball at each sample. 

<hr>

<div class="row">
<div class="nine columns mblurCompare">
  <a></a>
</div>
<div class="three columns">
  <p><strong>Hover over the image</strong> to see the effects of higher temporal sampling.</p>

  <p style="line-height: 1.3em; margin-bottom: 10px;"><strong>Samples per pixel:</strong><br> 10 / 100</p>
  <p style="line-height: 1.3em; margin-bottom: 10px;"><strong>Time to render:</strong><br>~60s / ~650s</p>
</div>
</div>

<div class="row">
<div class="nine columns">
  <img src="./mblur3.jpg" />
</div>
<div class="three columns">
  <p style="line-height: 1.3em; margin-bottom: 10px;"><strong>Samples per pixel:</strong><br> 100</p>
  <p style="line-height: 1.3em; margin-bottom: 10px;"><strong>Time to render:</strong><br>~650s</p>
</div>
</div>
