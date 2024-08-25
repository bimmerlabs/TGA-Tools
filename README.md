# TGA-Tools
## Tools for manipulating and exporting TGA graphics for Sega Saturn
Requires modern Perl version (5.38), no additional dependencies are required.
### Current Features:
- Read TGA images and parse the file header, palettes, and image data (currently expects 8 bit palettes only)
- Write SGL-format VDP2 palettes
- Write custom RGB palette and background header files for Sega Saturn [HSL Color model](https://github.com/bimmerlabs/saturn-demos/tree/7bba0a845603b19459b8e11edb12be7b0d5de724/demo%20-%20HSL%20color%20calc)
- Write TGA image slice with updated header
### Planned Features:
- Write SGL-format VDP2 cel/map files
- Auto-slice TGA images into tiles
- Generate baked normal-mapped images and neccesary data structures
- Sort and re-index paletted TGA images
