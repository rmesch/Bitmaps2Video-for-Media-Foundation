

# Bitmaps2Video for Media Foundation

 A VCL-based Delphi-class to encode a series of bitmaps and video-clips together with an audio file to video using the Windows Mediafoundation-API.

The encoding class TBitmapEncoderWMF can be found in Source\uBitmaps2VideoWMF.pas. 
It is designed to be an easy to use interface to the Mediafoundation-API, requiring only basic knowledge about video-processing.

<B>Requires</B>:

* The <B>MF-API-headers</B> available at https://github.com/FactoryXCode/MfPack. 
Download the repository and add its folder "src" to your library path. There is no need to install any package.
Thanks to FactoryXCode for the headers and samples!

* <B> Delphi-Versions:</B>
Developed under Delphi 11.3 - 12.1. Now designed to work with Delphi XE7 and up, unless I goofed it up again. 
Records with methods, anonymous procedures, interposer classes, tasks and TWicImage need to be available.

* <B> Windows-Versions:</B>
Windows 10 or above for full set of features. Windows 8 may work in a limited way, but untested. Will fail under
Windows 7 and below.

<B>Supported file formats and codecs:</B>

Output:  
Presently only .mp4 with H264 or H265(HEVC)-codecs. Hardware encoding is enabled if supported. Audio is encoded to AAC.
The required encoders (MF-Transforms) usually come with your graphics-driver.

Input:  
Theoretically anything that Windows has a decoder for should work as input for video or audio. 
Practically some file formats (like .vob) don't seem to be fully supported. Try them
in the demo. Rule of thumb: What Films & TV will play, works.

<B>Usage:</B>

Add the 4 files in the Source-directory to your project and the uses-clause of any unit using the encoder.
The methods of the encoder-class are explained in the interface section of uBitmaps2VideoWMF.pas.
To see examples of usage, run the demo-project DemoWMF in the Demo-folder. The repo no longer contains dproj-files. 
Before using the demo-project you should set the output directories to .\$(Platform)\$(Config) in the project options.


https://github.com/user-attachments/assets/76ef1f8a-45e1-43a0-87b1-4b4c86ac3f22



