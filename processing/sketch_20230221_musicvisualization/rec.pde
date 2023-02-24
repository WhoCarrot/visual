import com.hamoid.*;

VideoExport videoExport;

final String sketchname = getClass().getName();
final String SEPARATOR = "|";
float movieFPS = 144;
float frameDuration = 1 / movieFPS;
float frameOffset = 0.5;
BufferedReader reader;

void preAnalyzeAudio(String fileName) {
    PrintWriter output;

  Minim minim = new Minim(this);
  output = createWriter(dataPath(sketchname + ".txt"));

  AudioSample track = minim.loadSample(fileName, 2048);

  int fftSize = 1024;
  float sampleRate = track.sampleRate();

  float[] fftSamplesL = new float[fftSize];
  float[] fftSamplesR = new float[fftSize];

  float[] samplesL = track.getChannel(AudioSample.LEFT);
  float[] samplesR = track.getChannel(AudioSample.RIGHT);  

  FFT fftL = new FFT(fftSize, sampleRate);
  FFT fftR = new FFT(fftSize, sampleRate);

  fftL.logAverages(22, 3);
  fftR.logAverages(22, 3);

  int totalChunks = (samplesL.length / fftSize) + 1;
  int fftSlices = fftL.avgSize();

  for (int ci = 0; ci < totalChunks; ++ci) {
    int chunkStartIndex = ci * fftSize;   
    int chunkSize = min( samplesL.length - chunkStartIndex, fftSize );

    System.arraycopy( samplesL, chunkStartIndex, fftSamplesL, 0, chunkSize);      
    System.arraycopy( samplesR, chunkStartIndex, fftSamplesR, 0, chunkSize);      
    if ( chunkSize < fftSize ) {
      java.util.Arrays.fill( fftSamplesL, chunkSize, fftSamplesL.length - 1, 0.0 );
      java.util.Arrays.fill( fftSamplesR, chunkSize, fftSamplesR.length - 1, 0.0 );
    }

    fftL.forward( fftSamplesL );
    fftR.forward( fftSamplesL );

    // The format of the saved txt file.
    // The file contains many rows. Each row looks like this:
    // T|L|R|L|R|L|R|... etc
    // where T is the time in seconds
    // Then we alternate left and right channel FFT values
    // The first L and R values in each row are low frequencies (bass)
    // and they go towards high frequency as we advance towards
    // the end of the line.
    StringBuilder msg = new StringBuilder(nf(chunkStartIndex/sampleRate, 0, 3).replace(',', '.'));
    for (int i=0; i<fftSlices; ++i) {
      msg.append(SEPARATOR + nf(fftL.getAvg(i), 0, 4).replace(',', '.'));
      msg.append(SEPARATOR + nf(fftR.getAvg(i), 0, 4).replace(',', '.'));
    }
    output.println(msg.toString());
  }
  track.close();
  output.flush();
  output.close();
  println("Sound analysis done");
}

void initRecording(String audioFilePath) {
      preAnalyzeAudio(audioFilePath);
      
      reader = createReader(sketchname + ".txt");
      videoExport = new VideoExport(this, "../"+sketchname+".mp4");
      videoExport.setFrameRate(movieFPS);
      videoExport.setAudioFileName(audioFilePath);
      videoExport.startMovie();
}

float getSoundTime() {
    String line;
    try {
        line = reader.readLine();
    } catch (IOException e) {
        e.printStackTrace();
        line = null;
    }

    if (line == null) {
        videoExport.endMovie();
        exit();
    }

    String[] p = split(line, SEPARATOR);
    float soundTime = float(p[0]);
    
    return soundTime;
}

float getCurrentTime() {
  float currentTime = videoExport.getCurrentTime();
  
  return currentTime;
}

void recordFrame() {
    videoExport.saveFrame();
}

void keyPressed() {
    if (key == 'q') {
        videoExport.endMovie();
        exit();
    }
}
