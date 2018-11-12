package ucf.deskdrummer.micaudio

import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.PluginRegistry.Registrar

import android.media.AudioRecord
import android.media.AudioRecord.OnRecordPositionUpdateListener
import android.media.AudioFormat
import android.media.MediaRecorder
import android.content.pm.PackageManager
import android.Manifest


import kotlin.concurrent.thread

class MicAudioPlugin(private val mRegistrar: Registrar): MethodCallHandler, EventChannel.StreamHandler {
private lateinit var mRecorder: AudioRecord
private lateinit var mAudioData: ByteArray
private var mReadThreadRunning: Boolean = false
private var mEventSink: EventChannel.EventSink? = null

  companion object {
    @JvmStatic
    fun registerWith(registrar: Registrar): Unit {
      val plugin = MicAudioPlugin(registrar)
      val channel = MethodChannel(registrar.messenger(), "micAudio")
      channel.setMethodCallHandler(plugin)

      val eventChannel = EventChannel(registrar.messenger(), "micAudioStream")
      eventChannel.setStreamHandler(plugin)
    }
  }


  private fun initializeMicAudio(): Boolean {
    val potentialSampleRates = intArrayOf(44100, 22050, 16000, 11025, 8000)
    var sampleRate = 0
    val channel = AudioFormat.CHANNEL_IN_MONO
    val source = MediaRecorder.AudioSource.CAMCORDER
    val format = AudioFormat.ENCODING_PCM_8BIT
    var bufferSize = 0

    if (mRegistrar.context().checkSelfPermission(Manifest.permission.RECORD_AUDIO)
        != PackageManager.PERMISSION_GRANTED) {
      mRegistrar.activity().requestPermissions(arrayOf(Manifest.permission.RECORD_AUDIO), 0)
    }

    for (rate in potentialSampleRates) {
      bufferSize = AudioRecord.getMinBufferSize(rate, channel, format)
      if (bufferSize > 0) {
        sampleRate = rate
        break
      }
    }
    if (bufferSize < 1) return false

    mAudioData = ByteArray(bufferSize / 2)

    mRecorder = AudioRecord(source, sampleRate, channel, format, bufferSize)
    return mRecorder != null
  }

  override fun onListen(args: Any?, eventSink: EventChannel.EventSink) {
    mEventSink = eventSink
    thread(start = true) {
      mReadThreadRunning = true
      while (mReadThreadRunning) {
        if (mRecorder?.recordingState != AudioRecord.RECORDSTATE_RECORDING) {
          if (mRecorder?.state == AudioRecord.STATE_INITIALIZED) {
              mRecorder?.startRecording()
          }
        }
        val numRead = mRecorder?.read(mAudioData, 0, mAudioData.size)
        if (numRead != null) {
          for (i in mAudioData.indices) {
            mAudioData[i] = if (i >= numRead) -1 else mAudioData[i]
          }
        }
        mEventSink?.success(mAudioData)
      }
    }
  }

  override fun onCancel(args: Any?) {
    mReadThreadRunning = false
    mRecorder?.stop()
    mRecorder?.release()
    mEventSink = null
  }

  override fun onMethodCall(call: MethodCall, result: Result): Unit {
    when (call.method) {
      "getPlatformVersion" -> result.success("Android ${android.os.Build.VERSION.RELEASE}")
      "initializeMicAudio" -> result.success(initializeMicAudio())
      else -> result.notImplemented()
    }
  }
}


