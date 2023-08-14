# Bitmaps2Video for Media Foundation
 A Delphi-class to encode a series of bitmaps together with an audio file to video using the Windows Mediafoundation-API.

The encoding class TBitmapEncoderWMF can be found in Source\uBitmaps2VideoWMF.pas. It is designed to be an easy to use interface to the Mediafoundation-API, requiring only basic knowledge about video-processing.

Requires:
* The MF-API-headers available at https://github.com/FactoryXCode/MfPack. 
Download the repository and add its folder "src" to your library path. There is no need to install any package.
* Thanks to FactoryXCode for the headers and samples! 

Supported file formats and codecs:
Presently only .mp4 with H264 or H265(HEVC)-codecs. Hardware encoding is enabled if supported. Audio is encoded to AAC.

Usage:
Add the 3 files in the Source-directory to your project and the uses-clause of any unit using the encoder.
The methods of the encoder-class are explained in the interface section of uBitmaps2VideoWMF.pas.
To see examples of usage, run the demo-project DemoWMF in the Demo-folder.

Delphi-Versions:
Developed under Delphi 11.3. Should work with 10.3 and up, probably with some earlier versions, too. 
Extended records, anonymous procedures, interposer classes and TWicImage need to be available.

Runtime Requirement:
To be able to use all encoding features, Windows 10 or higher is required. 
