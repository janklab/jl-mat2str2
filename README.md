jl-mat2str2
===========

Extended `mat2str` functionality for Matlab.

The `jl-mat2str2` library provides extended `mat2str` functionality for Matlab in the form of a `mat2str2` function. Whereas Matlab’s `mat2str` only works on numerics, strings, and chars, `mat2str2` also supports cell, `datetime`, and `table` arrays. It also supports matrices with more than 2 dimensions.

## Installation

Copy the `jl-mat2str2` distribution somewhere on your disk, and add its `Mcode/` directory to your Matlab path.

## Usage

Call `mat2str2` on your arrays, just as you would with `mat2str`. See `doc mat2str` for more info.

## Project

`jl-mat2str2` is written by [Andrew Janke](https://apjanke.net).

The project lives on GitHub at <https://github.com/apjanke/jl-mat2str2>.

`jl-mat2str2` is part of the Janklab suite of Matlab libraries.
