[Journey to the End - Windir (feat. garlic0x1)](https://www.youtube.com/watch?v=gqubRzRq3xM)

Drum samples stolen from [here](https://github.com/gregharvey/drum-samples/tree/master/GSCW%20Drums%20Kit%201%20Samples)

This is a project for me to learn how to compose music with Supercollider.

# Usage

You should be able to run this with Supercollider and Quicklisp
installed, although it is only tested on a Mac with SBCL (Note that
the Supercollider GUI app should be run once for a complete install).

```lisp
(ql:quickload :windir)
(windir:start-server)

;; play music for 32 measures
(windir:play-song 32)

;; if you want to stop early (lame)
(windir:stop-server)
```

# Tips

For optimal results, interactively comment and uncomment measures in
the `melody-lines` function.  I like to start with just the first
variation, then add/remove measures and just play with it.

If you know the song you will recognize when to use the different parts.

The "measure" are the parts of `melody-lines` separated by `\n\n`, and
are randomly selected.

# TODO

Add some transitional sequences.

Improve synths, the ones used are pretty basic, I would like something
that imitates a black-metal tremolo and strings, unfortunately I don't
think stripping the vocals to overlay is possible.

Maybe add more measures, and fill out the thinner ones that only have
2 hands.