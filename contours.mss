@contour: lighten(brown, 30);
@contours-line-width: 0.5;
@contours-line-smooth: 0.9;   // A value from 0 to 1

@contours-medium-multiplier: 1.5;
@contours-major-multiplier: 2.0;


#contours10[zoom>=16] {
  line-color: lighten(@contour, 10);
  line-smooth: @contours-line-smooth;
  line-width: @contours-line-width;
  line-opacity: 0.4;
}

#contours50[zoom>=14] {
  line-color: lighten(@contour, 10);
  line-smooth: @contours-line-smooth;
  line-width: @contours-line-width * @contours-medium-multiplier;
  line-opacity: 0.5;
}

#contours200[zoom>=12] {
  line-color: @contour;
  line-smooth: @contours-line-smooth;
  line-width: @contours-line-width * @contours-major-multiplier;
  line-opacity: 0.5;
}
