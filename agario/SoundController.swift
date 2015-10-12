//
//  Recorder.swift
//  agario
//
//  Created by Yunhan Li on 10/12/15.
//
//

import AVFoundation

class SoundController : AVAudioRecorder, AVAudioRecorderDelegate {
    var soundRecorder : AVAudioRecorder!
    let fileName = "cache_recording.caf"

    override init() {
        super.init()
        setupRecorder()
    }
    
    // Set up the recorder
    func setupRecorder() {
        let recordSettings = [
            AVSampleRateKey : NSNumber(float: Float(32000.0)), //32KHz
            AVFormatIDKey : NSNumber(int: Int32(kAudioFormatAppleLossless)),
            AVNumberOfChannelsKey: NSNumber(int: 1),
            AVEncoderBitRateKey: 12800,
            AVLinearPCMBitDepthKey : 16,
            AVEncoderAudioQualityKey : NSNumber(int: Int32(AVAudioQuality.Medium.rawValue))];
 
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try soundRecorder = AVAudioRecorder(URL: self.getURL()!,
                settings: recordSettings)
            soundRecorder.delegate = self
            soundRecorder.prepareToRecord()
            soundRecorder.meteringEnabled = true
        } catch {
        }
        
        if !soundRecorder.recording {
            soundRecorder.record()
            let audioSession = AVAudioSession.sharedInstance()
            do {
                try audioSession.setActive(true)
                
            } catch {
            }
        }
    }
    
    func update() -> Float {
        soundRecorder.updateMeters()
        return soundRecorder.averagePowerForChannel(0)
    }

    func getURL() -> NSURL? {
        let fileManager = NSFileManager.defaultManager()
        let urls = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        let documentDirectory = urls[0] as NSURL
        let soundURL = documentDirectory.URLByAppendingPathComponent(fileName)
        return soundURL
    }
    
    func stopRecording() {
        soundRecorder.stop()
        let audioSession = AVAudioSession.sharedInstance()
        
        do {
            try audioSession.setActive(false)
        } catch {
        }
    }
    
    func audioRecorderDidFinishRecording(recorder: AVAudioRecorder, successfully flag: Bool) {
        print(soundRecorder.deleteRecording())
        print("recording cache removed")
    }

}