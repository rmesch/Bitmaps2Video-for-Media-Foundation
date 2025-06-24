// Project Location:
// https://github.com/rmesch/Bitmaps2Video-for-Media-Foundation
// Copyright © 2003-2025 Renate Schaaf
//
// Intiator(s): Renate Schaaf
// Contributor(s): Renate Schaaf,
//                 Tony Kalf (maXcomX) https://github.com/FactoryXCode/MfPack
//
// Release date: June 2025
// =============================================================================
// =============================================================================
//
// LICENSE
//
// The contents of this file are subject to the Mozilla Public License
// Version 2.0 (the "License"); you may not use this file except in
// compliance with the License. You may obtain a copy of the License at
// https://www.mozilla.org/en-US/MPL/2.0/
//
// Software distributed under the License is distributed on an "AS IS"
// basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
// License for the specific language governing rights and limitations
// under the License.
//
// Non commercial users may distribute this sourcecode provided that this
// header is included in full at the top of the file.
// Commercial users are not allowed to distribute this sourcecode as part of
// their product.
//
// =============================================================================
unit uToolsWMF;

interface

uses
  WinApi.Windows,
  WinApi.Wincodec,
  System.Types,
  VCL.Graphics,
  uScaleWMF,
  uScaleCommonWMF;

/// <summary> Assigns a TWICImage to a TBitmap without setting its alphaformat to afDefined. A TWICImage can be used for fast decoding of image formats .jpg, .bmp, .png, .ico, .tif. </summary>
procedure WICToBmp(const aWic: TWICImage; const aBmp: TBitmap);

/// Resizes Source to Target so Target fits into aRect aspect-preserving. DisplayRect is the subrect of aRect for centered display.
/// Returns false if resizing is not possible.
function MaximizeToRect(const Source:TBitmap; const Target: TBitmap; aRect: TRect; var DisplayRect: TRect): boolean;

implementation

procedure WICToBmp(const aWic: TWICImage; const aBmp: TBitmap);
var
  LWicBitmap: IWICBitmapSource;
  Stride: integer;
  Buffer: array of byte;
  BitmapInfo: TBitmapInfo;
  w, h: integer;
begin
  w := aWic.Width;
  h := aWic.Height;
  Stride := w * 4;
  SetLength(Buffer, Stride * h);

  WICConvertBitmapSource(GUID_WICPixelFormat32bppBGRA, aWic.Handle, LWicBitmap);
  LWicBitmap.CopyPixels(nil, Stride, Length(Buffer), @Buffer[0]);

  FillChar(BitmapInfo, sizeof(BitmapInfo), 0);
  BitmapInfo.bmiHeader.biSize := sizeof(BitmapInfo);
  BitmapInfo.bmiHeader.biWidth := w;
  BitmapInfo.bmiHeader.biHeight := -h;
  BitmapInfo.bmiHeader.biPlanes := 1;
  BitmapInfo.bmiHeader.biBitCount := 32;

  aBmp.SetSize(0, 0); // erase pixels
  aBmp.PixelFormat := pf32bit;

  // if the alphaformat was afDefined before, this is a good spot
  // for VCL.Graphics to do un-multiplication
  aBmp.AlphaFormat := afIgnored;

  aBmp.SetSize(w, h);
  SetDIBits(0, aBmp.Handle, 0, h, @Buffer[0], BitmapInfo, DIB_RGB_COLORS);
end;

function MaximizeToRect(const Source:TBitmap; const Target: TBitmap; aRect: TRect; var DisplayRect: TRect): boolean;
var
  wRect, hRect: integer;
  asp, aspRect: double;
  dLeft, dTop: integer;
begin
  Result := false;
  wRect := aRect.Right-aRect.Left;
  hRect := aRect.Bottom-aRect.Top;
  if (Source.Width=0) or (Source.Height=0) or (wRect=0) or (hRect=0) then
  exit;
  asp:=Source.Width/Source.Height;
  aspRect:=wRect/hRect;
  if asp>aspRect then //scale to wRect
  begin
    Target.Width:=wRect;
    Target.Height:=round(wRect/asp);
  end
  else
  begin
    Target.Height:=hRect;
    Target.Width:=round(hRect*asp);
  end;
  uScaleWMF.Resample(Target.Width,Target.Height,Source,Target,cfBicubic,0,true,amIgnore);
  dLeft:=(wRect-Target.Width) div 2;
  dTop:=(hRect-Target.Height) div 2;
  DisplayRect:=Rect(dLeft,dTop,dleft+Target.Width,dTop+Target.Height);
end;



end.
