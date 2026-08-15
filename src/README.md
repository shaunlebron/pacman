# notes on /src

All these files are cruedly concatenated in `build.sh`.  But I've made steps to
improve its readability:

## Old code style in 2012

I started writing this code in 2012 before JavaScript had proper modules. This
was also the first game I tried building, and I didn't have experience in
determing how to manage a lot of game state, i.e. where to put functions and
data. I did read the *JavaScript: The Good Parts* and made use of prototypes
and IIFEs for keeping data and functions together.

## Cleaning up in 2026

In 2026, I was surprised people were still looking at this code.  Looking back
now, I think there's still a lot of good stuff here worth preserving, so I took
baby steps toward making it more readable: block-scoped variables, marking some
as constants, and mentioning where all global references can be found. These
improvements are verified by a linter, added to `./build.sh`.

## Difficulty converting to modules

I had trouble making larger improvements, like converting global references to `import`s, since these files
have circular dependencies, causing the imports to be `undefined`.

## Future

Perhaps I (or someone) can approach this more strategically next time-- by
categorizing the kinds of things that need to be shared, determining who needs
them and why, and start moving things around.

If that works, it may help us better conceptualize and understand what is happening in the game,
continuing the original goal of this project.
