@contour: #66f;
@contour-text: @contour;

#contours {
  [zoom >= 7] {
    /* background prevents problems with overlapping contours, see #457 */
    background/line-color: @water-color;
    background/line-width: 1; /* Needs to be a bit wider than the route itself because of antialiasing */
    line-color: @contour;
    line-width: 0.4;
    line-dasharray: 4,4;
    [zoom >= 11] {
      background/line-width: 1;
      line-width: 0.8;
      line-dasharray: 6,6;
    }
  }
}

#contours-text {
  [zoom >= 13] {
    text-name: "[name]";
    text-face-name: @book-fonts;
    text-placement: line;
    text-fill: @contour-text;
    text-spacing: 1000;
    text-size: 10;
    text-dy: -8;
  }
}
