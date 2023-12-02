Advent of Code 2023 in OCaml (AOCaml)
===

This is my Advent of Code for 2023, which I decided on a whim to do in OCaml.
I chose OCaml because it's a language I've been learning the last few months and that I've really taken to.
It is a functional programming language with imperative programming capabilities (like the inverse of Rust; Rust's type system is acutally based on OCaml's!).
I'd say if you want to dip your toes into functional programming, OCaml is a good place to start, since it's super expressive and has escape hatches if you have a hard time solving problems functionally.
There's even objects if you're in to that (the "O" in "OCaml" stands for "objective").

Since this is my first real "project" in OCaml, expect the code to be kind of wonky and suboptimal.
I may overcomplicate things, try to reinvent a standard library function, and use language features I don't necessarily need.
This endeavor is meant as a learning exercise, basically.

Here is how I will try to do this:
1. Do each AoC problem the day it's released.
1. Solve parts 1 and 2 separately.
1. Commit the code I used to solve the problem.
1. Refactor and clean up the code, and commit the cleaned up version.
1. Do a little write-up on this README reflecting on the problem and my solution, and commit that.
1. Push all commits for that day to GitHub *the next day*, as not to spoil people.
1. Once I start on the next problem, I will refrain from editing code for previous problems.

And just for posterity's sake, here are my tools:
- Operating system: Arch Linux (kernel version 6.5.7-arch1-1)
- Shell: Nushell (0.85.0)
- Terminal: Alacritty (0.12.3)
- Editor: Helix (23.10)
- Terminal multiplexer: Zellij (0.38.2)
- OCaml: 5.1.0
- Dune: 3.11.1
- OCaml LSP: 1.16.2

Here's to a Merry Coding!

## Day 1

The first part was no big deal.
I hacked together a little parser that parses `char option * char option` where, when it encounters a digit in each line, does the following: 
- If the first `char option` is `None`, set it to `Some` with a value of that (unparsed) digit.
- Otherwise, set the second `char option` to `Some` with that digit.

Of note, this parses the whole string *going in one direction (left-to-right)*.

Once I resolved all the compiler errors, this worked on my first try!
OCaml is one of those languages where if your code compiles, it probably does what you want.
This is because you can easily write immutable code and the type system is really good at letting you model your problem space correctly
(though it's not quite as good as Haskell in this regard; few languages are).

The second part was a doozy. Rather than asking you to just parse single digits as numbers, you're asked also to parse words as numbers.
So `"one"` should be parsed as `1`, `"two"` as `2`, etc.
Immediately, I felt my choice of OCaml was fortuitous, since this seemed like a job for parser combinators, which are pretty easy to write in functional languages.
But I didn't wanna waste a ton of time writing a bunch of combinators, so I settled on something a little less flexible.
However, I was still thinking about parsing only left-to-right in one pass, which caused a bug.
See, I didn't pick up that the problem wanted you to search the string from the left to get the tens digit, then from the right to get the ones digit.
This caused an issue if there was something like "fiveight" at the end of the string, since my parser would parse "five" as 5, then the rest of the string would be "ight", which doesn't parse to anything.
But in fact the problem intends for "eight" to get parsed. 
Overall, this happened to result in my answer being too small so I had to rework the code.

Instead of parsing from left-to-right in one pass, I wrote my parser to parse in two passes:
first it parses left-to-right to get the tens digit, then it parses right-to-left to get the ones digit.
This made the code a little more complicated because while the left-to-right parser parses "four" as 4, the right-to-left parser will have to parse "ruof" as 4.
This basically boiled down to adding a few match statements, which are a little noisy.
But after this rework and after resolving all the type errors, I ran it again and got the right answer!
At this point it was like 1 AM so I put it down and went to bed.

The next day, I came back and refactored the code
(1) to share the parsing logic between parts 1 and 2, and
(2) so that my project was better structured overall.
I found that I could refactor the parsing logic for part 2 into a functor module and then just define a module for each part with a list of tokens and a function to convert a token to a digit.
Then I just call the parser functor on each of those modules and **BOOM** very nice refactor, if I may be so bold.

I think a lot of the challenge (besides, you know, the challenge problem) was getting used to OCaml's syntax, especially for pattern-matching.
I wrote some pretty ugly pattern matches that I could probably have made better if I were a little more familiar with the syntax.
I also spent a long time scrolling through auto-completion to find stuff; that's obviously something I'll get better at with time.
Helix is a pretty new text editor I've been trying out and I'm definitely very slow with it, and I need to remember to go back into normal mode before trying to navigate around.
But again, that's something that comes with time and experience, and I think I like it enough to stick with it.
Overall, this was a really fun day 1, and I'm looking forward to the rest of this AoC!

