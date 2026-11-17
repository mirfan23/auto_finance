package com.example.auto_finance

import android.content.Context
import com.google.ai.edge.litertlm.Backend
import com.google.ai.edge.litertlm.ConversationConfig
import com.google.ai.edge.litertlm.Engine
import com.google.ai.edge.litertlm.EngineConfig
import com.google.ai.edge.litertlm.SamplerConfig
import kotlinx.coroutines.flow.collect
import kotlinx.coroutines.runBlocking
import java.io.BufferedInputStream
import java.io.File
import java.io.FileOutputStream
import java.net.HttpURLConnection
import java.net.URL

/** Downloads and runs a pinned, text-only Qwen3 INT4 model entirely on device. */
class LocalAiModelManager(
    context: Context,
    private val onDownloadProgress: (Long, Long) -> Unit,
) {
    companion object {
        const val EXPECTED_DOWNLOAD_BYTES = 347L * 1024L * 1024L
        private const val MIN_VALID_MODEL_BYTES = 100L * 1024L * 1024L
        private const val MODEL_FILE_NAME = "qwen3_0.6b_nothink_q4_block32_ekv1280.litertlm"
        private const val MODEL_URL =
            "https://huggingface.co/litert-community/Qwen3-0.6B-int4/resolve/6aa2daf/qwen3_0.6b_nothink_q4_block32_ekv1280.litertlm?download=true"
    }

    private val appContext = context.applicationContext
    private val modelDirectory = File(appContext.filesDir, "local_ai")
    private val modelFile = File(modelDirectory, MODEL_FILE_NAME)
    private val partialFile = File(modelDirectory, "$MODEL_FILE_NAME.part")

    @Volatile private var engine: Engine? = null

    @Synchronized
    fun modelStatus(): Map<String, Any> = mapOf(
        "downloaded" to isModelDownloaded(),
        "sizeBytes" to if (isModelDownloaded()) modelFile.length() else 0L,
        "expectedBytes" to EXPECTED_DOWNLOAD_BYTES,
    )

    fun isModelDownloaded(): Boolean = modelFile.isFile && modelFile.length() >= MIN_VALID_MODEL_BYTES

    fun downloadModel(): Long {
        if (isModelDownloaded()) return modelFile.length()

        modelDirectory.mkdirs()
        partialFile.delete()

        val connection = (URL(MODEL_URL).openConnection() as HttpURLConnection).apply {
            instanceFollowRedirects = true
            connectTimeout = 30_000
            readTimeout = 90_000
            requestMethod = "GET"
            setRequestProperty("User-Agent", "AutoFinance/LocalAI")
        }

        try {
            connection.connect()
            if (connection.responseCode !in 200..299) {
                throw IllegalStateException("Unduhan model gagal (HTTP ${connection.responseCode}).")
            }
            val totalBytes = connection.contentLengthLong.takeIf { it > 0 } ?: EXPECTED_DOWNLOAD_BYTES
            var downloaded = 0L
            BufferedInputStream(connection.inputStream).use { input ->
                FileOutputStream(partialFile).use { output ->
                    val buffer = ByteArray(128 * 1024)
                    var read = input.read(buffer)
                    while (read >= 0) {
                        if (read > 0) {
                            output.write(buffer, 0, read)
                            downloaded += read
                            onDownloadProgress(downloaded, totalBytes)
                        }
                        read = input.read(buffer)
                    }
                    output.fd.sync()
                }
            }
            if (partialFile.length() < MIN_VALID_MODEL_BYTES) {
                throw IllegalStateException("Berkas model tidak lengkap atau terlalu kecil.")
            }
            if (modelFile.exists()) modelFile.delete()
            if (!partialFile.renameTo(modelFile)) {
                throw IllegalStateException("Berkas model tidak dapat disimpan.")
            }
            return modelFile.length()
        } catch (error: Exception) {
            partialFile.delete()
            throw error
        } finally {
            connection.disconnect()
        }
    }

    @Synchronized
    fun parse(prompt: String): String {
        check(isModelDownloaded()) { "Model AI lokal belum diunduh." }
        val localEngine = engine ?: Engine(
            EngineConfig(
                modelPath = modelFile.absolutePath,
                backend = Backend.CPU(),
                cacheDir = File(appContext.cacheDir, "local_ai").apply { mkdirs() }.absolutePath,
            ),
        ).also {
            it.initialize()
            engine = it
        }

        val conversation = localEngine.createConversation(
            ConversationConfig(
                samplerConfig = SamplerConfig(topK = 1, topP = 1.0, temperature = 0.0),
            ),
        )
        return try {
            val output = StringBuilder()
            runBlocking {
                conversation.sendMessageAsync(prompt).collect { message ->
                    output.append(message.toString())
                }
            }
            output.toString()
        } finally {
            conversation.close()
        }
    }

    @Synchronized
    fun deleteModel() {
        engine?.close()
        engine = null
        modelFile.delete()
        partialFile.delete()
    }
}
