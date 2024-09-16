//
//  ContentView.swift
//  Tomi
//
//  Created by Leticia França on 11/09/24.
//

import SwiftUI

struct ContentView: View {
    @State var tempoAtual = 15
    @State var timer: Timer? = nil
    @State var isCorrendo = false
    @State var isTarefa = true
    @State var horarioInicio: Date? = nil
    @State var listaInvertalos: [String] = []
    @State var cicloPomodoro = 0

    let minutosTarefa = 1500
    let minutosPausa = 300

    // alta ordem
    func atualizarListaIntervalo(completion: (String) -> Void) {
        let faseCiclo = isTarefa ? "Pausa" : "Trabalho"
        completion("Tempo de \(faseCiclo) iniciado.")
    }
    
    // closure (lambda)
    func formatarTempoRestante() -> (Int) -> String {
        return { segundos in
            let minutos = segundos / 60
            let segundosRestantes = segundos % 60
            return String(format: "%02d:%02d", minutos, segundosRestantes)
        }
    }
    
    func controllerTimer() {
        if isCorrendo {
            timer?.invalidate()
            isCorrendo = false
        } else {
            horarioInicio = Date()
            iniciarTimerToggle()
        }
    }
    
    func resetarTimer() {
        timer?.invalidate()
        tempoAtual = isTarefa ? minutosTarefa : minutosPausa
        isCorrendo = false
    }
    
    func togglePausaTarefa() {
        let tempoCorrido = Date().timeIntervalSince(horarioInicio ?? Date())
        // usando a funçao de alta ordem
        atualizarListaIntervalo { novoIntervalo in
            listaInvertalos.append(novoIntervalo)
        }
        timer?.invalidate()
        isTarefa.toggle()
        tempoAtual = isTarefa ? minutosTarefa : minutosPausa
        iniciarTimerToggle()
    }
    
    func iniciarTimerToggle() {
        horarioInicio = Date()
        // usando o closure
        let updateTimer: (Timer) -> Void = { _ in
            if self.tempoAtual > 0 {
                self.tempoAtual -= 1
            } else {
                self.togglePausaTarefa()
            }
        }
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: updateTimer)
        isCorrendo = true
    }
    
    // map
    var formattedIntervals: [String] {
        listaInvertalos.map { interval in
            "Intervalo: \(interval)"
        }
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Text(isTarefa ? "Tempo de Trabalho" : "Tempo de Pausa")
                .font(.largeTitle)
                .padding()
            
            Text(formatarTempoRestante()(tempoAtual))
                .font(.system(size: 64))
                .bold()
                .padding()
            
            HStack(spacing: 40) {
                Button(action: controllerTimer) {
                    Image(systemName: isCorrendo ? "pause.fill" : "play.fill")
                            .font(.title)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .clipShape(Circle())
                }
                
                Button(action: resetarTimer) {
                    Image(systemName: "arrow.uturn.left")
                            .font(.title)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .clipShape(Circle())
                }
            }
            
            ScrollView {
                VStack(alignment: .leading) {
                    Text("Intervalos:")
                        .font(.headline)
                    ForEach(formattedIntervals, id: \.self) { interval in
                        Text(interval)
                            .padding(.bottom, 2)
                    }
                }
            }
            .frame(maxHeight: 200)
            .padding(.top, 20)
        }
        .onDisappear {
            timer?.invalidate()
        }
    }
}

#Preview {
    ContentView()
}
