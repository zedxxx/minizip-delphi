program libminizip_test;

{$APPTYPE CONSOLE}

uses
  SysUtils,
  DateUtils,
  libminizip in '..\libminizip.pas';

const
  CWriteCount = 100;
  CTestFileSize = 200*1024;
  CTestFileName = 'mz_delphi_test.zip';

procedure DoTestWrite(const AData: Pointer; const ADataSize: int32_t);
var
  I: Integer;
  VWriter: Pointer;
  VZipFileName: mz_string_t;
  VFileNameInZip: mz_string_t;
  VFileInfo: mz_zip_file;
  VCompressMethod: uint16_t;
  VCompressLevel: int16_t;
  VVolumSize: int64_t;
begin
  VCompressMethod := MZ_COMPRESS_METHOD_DEFLATE;
  VCompressLevel := MZ_COMPRESS_LEVEL_DEFAULT;
  VVolumSize := 0;

  mz_check( mz_zip_writer_create(VWriter) );
  try
    mz_zip_writer_set_compress_method(VWriter, VCompressMethod);
    mz_zip_writer_set_compress_level(VWriter, VCompressLevel);

    VZipFileName := mz_string_encode(CTestFileName);
    mz_check( mz_zip_writer_open_file(VWriter, @VZipFileName[1], VVolumSize, 0) );
    try
      for I := 0 to CWriteCount - 1 do begin
        VFileNameInZip := mz_string_encode('MyFileName_' + IntToStr(I) + '.bin');

        writeln('Writing file: ', mz_string_decode(VFileNameInZip));

        FillChar(VFileInfo, SizeOf(VFileInfo), 0);

        VFileInfo.filename := @VFileNameInZip[1];
        VFileInfo.creation_date := DateTimeToUnix(Now);
        VFileInfo.accessed_date := VFileInfo.creation_date;
        VFileInfo.modified_date := VFileInfo.creation_date;

        VFileInfo.compression_method := VCompressMethod;

        mz_check( mz_zip_writer_add_buffer(VWriter, AData, ADataSize, @VFileInfo) );
      end;
    finally
      mz_check( mz_zip_writer_close(VWriter) );
    end;
  finally
    mz_zip_writer_delete(VWriter);
  end;
end;

procedure DoTestRead(var AData: Pointer; const ADataSize: Integer);
var
  VErr: int32_t;
  VReader: Pointer;
  VZipFileName: mz_string_t;
  VFileInfo: p_mz_zip_file;
  VDataSize: int64_t;
  VEntrySize: int64_t;
  VCount: Integer;
begin
  VCount := 0;
  VDataSize := ADataSize;

  mz_check( mz_zip_reader_create(VReader) );
  try
    VZipFileName := mz_string_encode(CTestFileName);
    mz_check( mz_zip_reader_open_file(VReader, @VZipFileName[1]) );
    try
      VErr := mz_zip_reader_goto_first_entry(VReader);
      while VErr <> MZ_END_OF_LIST do begin
        mz_check(VErr);

        mz_check( mz_zip_reader_entry_get_info(VReader, VFileInfo) );

        VEntrySize := VFileInfo.uncompressed_size;
        if VEntrySize > 0 then begin
          if VDataSize < VEntrySize then begin
            VDataSize := VEntrySize;
            ReallocMem(AData, VDataSize);
          end;

          mz_check( mz_zip_reader_entry_save_buffer(VReader, AData, VDataSize) );
        end;

        writeln( mz_string_decode(VFileInfo.filename), ', size: ',  VEntrySize);
        Inc(VCount);

        VErr := mz_zip_reader_goto_next_entry(VReader);
      end;
      writeln('Total: ', VCount);
    finally
      mz_check( mz_zip_reader_close(VReader) );
    end;
  finally
    mz_zip_reader_delete(VReader);
  end;
end;

var
  VData: Pointer;
begin
  {$IFDEF DEBUG}
  ReportMemoryLeaksOnShutdown := True;
  {$ENDIF}
  try
    LoadLibMiniZip;

    VData := GetMemory(CTestFileSize);
    try
      DoTestWrite(VData, CTestFileSize);
      DoTestRead(VData, CTestFileSize);
    finally
      FreeMem(VData);
    end;
  except
    on E: Exception do begin
      Writeln(E.ClassName, ': ', E.Message);
    end;
  end;
  Writeln('Press Enter to exit...');
  Readln;
end.
