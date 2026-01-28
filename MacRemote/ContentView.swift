import Network
import SwiftUI

struct ContentView: View {
    @State private var isPlaying = false
    @State private var volume: Double = 0.5
    private let commandSender = CommandSender()

    var body: some View {
        #if os(iOS)
            ZStack {
                // Background
                LinearGradient(
                    colors: [.black, .gray.opacity(0.6)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack(spacing: 28) {
                    // Header
                    VStack(spacing: 8) {
                        HStack(spacing: 8) {
                            Circle()
                                .fill(Color.green)
                                .frame(width: 8, height: 8)
                            Text("Connected")
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.9))
                        }
                        .padding(.vertical, 6)
                        .padding(.horizontal, 10)
                        .background(.ultraThinMaterial, in: Capsule())
                        .overlay(
                            Capsule()
                                .strokeBorder(
                                    Color.white.opacity(0.15),
                                    lineWidth: 1
                                )
                        )

                        Text("Prakhar's MacBook Pro")
                            .font(.headline)
                            .foregroundStyle(.white)
                    }

                    Spacer()

                    // Play / Pause Button
                    Button {
                        #if os(iOS)
                            UIImpactFeedbackGenerator(style: .medium)
                                .impactOccurred()
                        #endif
                        isPlaying.toggle()
                        commandSender.send(.playPause)
                    } label: {
                        Image(
                            systemName: isPlaying ? "pause.fill" : "play.fill"
                        )
                        .font(.system(size: 48))
                        .contentTransition(.symbolEffect(.replace))
                        .symbolEffect(.bounce, value: isPlaying)
                        .foregroundStyle(.white)
                        .frame(width: 120, height: 120)
                        .background(.ultraThinMaterial, in: Circle())
                        .shadow(
                            color: .white.opacity(0.12),
                            radius: 12,
                            x: 0,
                            y: 8
                        )
                        .modifier(GlassHighlight())
                    }
                    .buttonStyle(PressEffectButtonStyle())

                    // Seek controls
                    HStack(spacing: 32) {
                        Button {
                            #if os(iOS)
                                UIImpactFeedbackGenerator(style: .light)
                                    .impactOccurred()
                            #endif
                            commandSender.send(.seekBackward(seconds: 10))
                        } label: {
                            Image(systemName: "gobackward.10")
                                .font(.system(size: 28, weight: .semibold))
                                .foregroundStyle(.white)
                                .frame(width: 80, height: 80)
                                .background(.ultraThinMaterial, in: Circle())
                                .shadow(
                                    color: .white.opacity(0.12),
                                    radius: 12,
                                    x: 0,
                                    y: 8
                                )
                                .modifier(GlassHighlight())
                        }
                        .contentShape(Circle())
                        .buttonStyle(PressEffectButtonStyle())

                        Button {
                            #if os(iOS)
                                UIImpactFeedbackGenerator(style: .light)
                                    .impactOccurred()
                            #endif
                            commandSender.send(.seekForward(seconds: 10))
                        } label: {
                            Image(systemName: "goforward.10")
                                .font(.system(size: 28, weight: .semibold))
                                .foregroundStyle(.white)
                                .frame(width: 80, height: 80)
                                .background(.ultraThinMaterial, in: Circle())
                                .shadow(
                                    color: .white.opacity(0.12),
                                    radius: 12,
                                    x: 0,
                                    y: 8
                                )
                                .modifier(GlassHighlight())
                        }
                        .contentShape(Circle())
                        .buttonStyle(PressEffectButtonStyle())
                    }
                    .padding(.top, 4)

                    Spacer()

                    // Volume slider
                    VStack(spacing: 12) {
                        Image(systemName: "speaker.wave.2.fill")
                            .foregroundStyle(.white)

                        Slider(value: $volume)
                            .tint(.white)
                            .onChange(of: volume) { oldValue, newValue in
                                #if os(iOS)
                                    UISelectionFeedbackGenerator()
                                        .selectionChanged()
                                #endif
                                commandSender.send(.setVolume(level: newValue))
                            }
                    }
                    .padding()
                    .background(
                        .ultraThinMaterial,
                        in: RoundedRectangle(cornerRadius: 20)
                    )
                }
                .padding()
            }
        #elseif os(macOS)
            VStack(spacing: 16) {
                Image(systemName: "play.circle")
                    .font(.system(size: 48))
                    .foregroundStyle(.tint)

                Text("Mac Remote is running")
                    .font(.headline)

                Text("This Mac is ready to receive media control commands.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding()
        #endif
    }
}

private class CommandSender {

    private let connection: NWConnection

    init() {
        connection = NWConnection(
            host: "127.0.0.1",  // 👈 YOUR MAC IP HERE
            port: 5555,
            using: .tcp
        )
        connection.start(queue: .main)
    }

    func send(_ command: MediaCommand) {
        guard let data = try? JSONEncoder().encode(command) else { return }

        connection.send(
            content: data,
            completion: .contentProcessed { error in
                if let error {
                    print("❌ Send error:", error)
                } else {
                    print("📤 Sent to Mac:", command)
                }
            }
        )
    }
}

#if os(iOS)
    private struct GlassHighlight: ViewModifier {
        func body(content: Content) -> some View {
            content
                .overlay(
                    Circle()
                        .strokeBorder(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.35),
                                    Color.white.opacity(0.05),
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.0
                        )
                        .blendMode(.screen)
                )
                .overlay(
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color.white.opacity(0.18), Color.clear,
                                ],
                                center: .topLeading,
                                startRadius: 2,
                                endRadius: 80
                            )
                        )
                        .blur(radius: 6)
                        .allowsHitTesting(false)
                )
        }
    }
#endif

#if os(iOS)
    private struct PressEffectButtonStyle: ButtonStyle {
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
                .opacity(configuration.isPressed ? 0.9 : 1.0)
                .animation(
                    .easeOut(duration: 0.12),
                    value: configuration.isPressed
                )
        }
    }
#endif
