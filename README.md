# RIZZ
(short for Rails Image Server Service)

This is a proof-of-concept IIIF image server.

* Using Kakadu via Libvips for JP2 support.

## Supported features
### Image requests
#### Region
- [x] full
- [x] square
- [x] x,y,w,h
- [x] pct:x,y,w,h

#### Size
- [x] max
- [x] ^max
- [x] w,
- [x] ^w,
- [x] ,h
- [x] ^,h
- [x] pct:n
- [x] ^pct:n
- [x] w,h
- [x] ^w,h
- [x] !w,h
- [x] ^!w,h

#### Rotation
- [x] n
- [x] !n

#### Quality
- [x] color
- [x] gray
- [x] bitonal
- [x] default

#### Format
- [x] jpg
- [x] tif
- [x] png
- [x] gif
- [x] jp2
- [x] pdf
- [x] webp

### Image information
- [x] required info
- [?] sizes
- [?] tiles

### Caching
- [x] file based caching
- [ ] cache pruning (operation that keeps cache below a max size by deleting least recently used)

### Other
- [x] CORS headers

## Development
### Building the Kakadu VIPS docker image
Caveats:
 * This works on an M1 Mac.
 * This requires a Kakadu license and access to the SDK.

1. Clone https://github.com/harvard-lts/kakadu-vips
2. Copy `Dockerfile-kakadu-vips` to the clone repository, renaming to `Dockerfile`.
3. Unzip the Kakadu SDK into the `kakadu` directory.
4. Build the image with `docker build . -t sul-dlss/kakadu-vips:latest`. You may need to provide additional build arguments for your architecture and Kakadu version. See the dockerfile.

### Running the development server
`docker run --rm -v $(pwd):/rizz -p 3000:3000 -it $(docker build -q .)`

The application will now be running on `http://localhost:3000`.

Example: http://localhost:3000/image-server/0380_796-44.jp2/full/max/0/default

### Image files
Image files can be placed in the `images` directory. They can be referenced by using their filename as the identifier.

For example, `http://localhost:3000/image-server/0380_796-44.jp2/full/max/0/default` serves `images/0380_796-44.jp2`.