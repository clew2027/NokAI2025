//
//  Services.swift
//  NokAI
//
//  Created by Charlotte Lew on 6/26/25.
//
import Foundation

class ASRService {
    func transcribeLiveAudio(data: Data, completion: @escaping (String) -> Void) {
        // Placeholder for Whisper/OpenAI
        completion("Hello, how are you?")
    }
}

class TranslationService {
    func translate(text: String, completion: @escaping (String) -> Void) {
        // Placeholder for Google Translate/DeepL
        completion("Hola, ¿cómo estás?")
    }
}
