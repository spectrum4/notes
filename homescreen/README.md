I've made a short go program to "scale up" the original +2A home screen into
one that is 1920x1280.  It outputs the pixel data which can be used to populate
the framebuffer, for the first pass. In the final version of the ZX Spectrum
+4, the home screen will be drawn, rather than stored as a huge image binary,
but for the purposes of getting things going, and designing the new home
screen, this was a quick way to render something in the appropriate resolution
(1920x1200).

When you run it (e.g. with `go run homescreen.go`) it will generate
`screen.png` which is the home screen. It will write the raw pixel data in hex
to standard out, which can be embedded in the kernel for the first experiment.
Each line is a single pixel, stored in 32 bits: (8 x red, 8 x green, 8 x blue,
8 x transparency).
