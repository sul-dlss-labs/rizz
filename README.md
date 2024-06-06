# RIZZ
(short for Rails Image Server Service)

This is a proof-of-concept IIIF image server.

* Using Kakadu via Libvips for JP2 support.
* Uses Falcon as web server.

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
- [ ] pct:n
- [ ] ^pct:n
- [x] w,h
- [x] ^w,h
- [ ] !w,h
- [ ] ^!w,h

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
- [ ] pdf
- [x] webp

### Image information
Not yet supported.

## Caveats
* No tests yet.
* No caching.
* I haven't fully read the IIIF Image API spec.

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
`docker run -v $(pwd):/rizz -p 3000:3000 -it $(docker build -q .)`

The application will now be running on `https://localhost:3000`. Note that you will need to accept the self-signed certificate.

Example: https://localhost:3000/image-server/0380_796-44/full/max/0/default

### Image files
JP2 image files can be placed in the `images` directory. They can be referenced by using their base filename as the identifier.

For example, `https://localhost:3000/image-server/0380_796-44/full/max/0/default` serves `images/0380_796-44.jp2`.