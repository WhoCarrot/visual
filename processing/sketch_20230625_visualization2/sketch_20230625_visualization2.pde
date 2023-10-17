import com.krab.lazy.*;
import ddf.minim.analysis.*;
import ddf.minim.*;

LazyGui gui;
AudioPlayer player;
FFT fft;

String currentSong;
String[] songNames;

float[][] grid;

String[] loadSongNames() {
    java.io.File folder = new java.io.File(dataPath("../../data"));
    String[] songNames = folder.list();
    java.util.Arrays.sort(songNames);
    return songNames;
}

void loadSong() {
    if (player != null) {
        player.pause();
    }
    currentSong = gui.radio("music/song", songNames);
    player = new Minim(this).loadFile(dataPath("../../data/" + currentSong));
    fft = new FFT(player.bufferSize(), player.sampleRate());
    gui.slider("music/position", 0, 0, 100);
}

float getSongPercentage() {
    return map(player.position(), 0, player.length(), 0, 100);
}

void setPlaying() {
    if (gui.toggle("music/play") && !player.isPlaying()) {
        player.play();
    } else if (!gui.toggle("music/play") && player.isPlaying()) {
        player.pause();
    }
}

float spLastValue;
float spChangeTime;
boolean spChanged = false;
void setPosition() {
    float sp = gui.slider("music/positionSet", 0, 0, 100);
    
    if (sp != 0 && sp != spLastValue) {
        spLastValue = sp;
        spChangeTime = millis();
        spChanged = true;
    }
    
    if (spChanged && millis() - spChangeTime > 500) {
        player.cue(round(map(sp, 0, 100, 0, player.length())));
        spChanged = false;
        gui.sliderSet("music/positionSet", 0);
    }
    
    gui.sliderSet("music/position", getSongPercentage());
}

void setSong() {
    if (gui.radio("music/song", songNames) != currentSong) {
        loadSong();
        return;
    }
}

void setup() {
    size(1200, 1200, P2D);
    
    gui = new LazyGui(this);
    songNames = loadSongNames();
    loadSong();
    
    smooth();
}

void analyzeFrame() {
    if (player.isPlaying()) fft.forward(player.mix);
    
    int cols = gui.sliderInt("grid/cols", 16, 1, 128);
    int rows = gui.sliderInt("grid/rows", 32, 1, 128);
    
    if (grid == null || grid.length != cols || grid[0].length != rows) {
        grid = new float[cols][rows];
    }
    
    for (int i = 0; i < fft.specSize() / 2; i++) {
        if (i >= cols) {
            break;
        }
        
        for (int row = rows - 1; row > 0; row--) {
            grid[i][row] = grid[i][row - 1];
        }
        
        grid[i][0] = fft.getBand(i);
    }
}

void draw() {
    background(0);
    
    setSong();
    setPosition();
    setPlaying();
    
    analyzeFrame();
    
}

void keyPressed() {
    if (key == ' ') {
        gui.toggleSet("music/play", !player.isPlaying());
    } else if (key == CODED) {
        if (keyCode == RIGHT) {
            player.cue(min(player.position() + 5000, player.length()));
        } else if (keyCode == LEFT) {
            player.cue(max(player.position() - 5000, 0));
        }
    }
}