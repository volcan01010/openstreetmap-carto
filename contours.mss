@contour: lighten(brown, 30);
@contours-line-width: 1;
@contours-line-smooth: 0.9;   // A value from 0 to 1

@contours-z12: 0.20;
@contours-z13: 0.30;
@contours-z14: 0.40;
@contours-z15: 0.50;
@contours-medium-multiplier: 1.5;
@contours-major-multiplier: 2.0;


#contours10[zoom>=16][zoom<=20] {
  line-color: green;
  line-width: @contours-line-width;
  line-smooth: @contours-line-smooth;
  line-cap: round;
  line-opacity: 0.3;
}

#contours50[zoom>=14][zoom<=20] {
  line-color: blue;
  line-width: @contours-line-width * @contours-medium-multiplier;
  line-smooth: @contours-line-smooth;
  line-cap: round;
  [zoom>14][zoom<=16] { line-opacity: 0.2; }
  [zoom>16] { line-opacity: 0.3; }
}

#contours200[zoom>=12][zoom<=14] {
  line-color: @contour;
  line-smooth: @contours-line-smooth;
  line-cap: round;
  [zoom=12] {
    line-opacity: 0.15;
    line-width: @contours-line-width * @contours-major-multiplier;
    line-color: @contour; }
  [zoom=13] { 
    line-opacity: 0.15;
    line-width: @contours-line-width * contours-medium-multiplier;
    line-color: @contour; }
}
