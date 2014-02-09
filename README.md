**Some image functions**


```coffee
{subbmp} = require 'rs-image'
```


## BMPs

So far we only support single-plane 24-bit RGB 54-byte-header uncompressed minimal-metadata BMPs.

That's the kind that `ffmpeg ... -f image2pipe -c bmp -` produces.

### subbmp

Efficiently create a BMP of a rectangular part of a BMP:

```coffee
clip_bmp_data = subbmp bmp_data, {x, y, width, height}
```


## [License: MIT](LICENSE.txt)
