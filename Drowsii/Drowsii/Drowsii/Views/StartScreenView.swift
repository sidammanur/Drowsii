import SwiftUI

struct StartScreenView: View {
    @Binding var didStart: Bool
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Background
                Color("MidnightBlue").ignoresSafeArea()
                
                // Large circle at the bottom
                Circle()
                    .fill(Color("CircleBlue"))
                    .frame(width: geo.size.width * 1.75, height: geo.size.width * 1.75)
                    .offset(x: -geo.size.width * 0.7, y: geo.size.height * 0.45)
                    // Telescope on the left edge of the circle
                Image("Telescope")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: geo.size.width * 0.28)
                    .offset(x: -geo.size.width * 0.7, y: -geo.size.height * 0.02)
                
                // Moon and constellation at the top
                HStack {
                    Image("Drowsii Group 3")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: geo.size.width * 0.65)
                        .padding(.leading, geo.size.width * 0.08)
                        .offset(x: -geo.size.width * 0.3, y: -geo.size.width * 0.2)
                    Spacer()
                }
                .padding(.top, geo.size.height * 0.08)
                .frame(width: geo.size.width, height: geo.size.height, alignment: .topLeading)
                
                // drowsii logo centered vertically
                VStack {
                    Spacer()
                    Text("drowsii.")
                        .font(.system(size: 38, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .shadow(color: Color("White").opacity(0.35), radius: 8, x: -5, y: 6)
                        .offset(x: -geo.size.width * 0.35, y: -geo.size.width * 0.4)
                    Spacer()
                }
                .frame(width: geo.size.width, height: geo.size.height)
                .ignoresSafeArea()
                
                // Subtitle and button at the bottom, on top of the circle
                VStack(spacing: 20) {
                    Spacer()
                    (
                        Text("your ")
                            .font(.system(size: 17, weight: .regular, design: .rounded))
                            .foregroundColor(.white)
                        + Text("fully customizable")
                            .font(.system(size: 17, weight: .semibold, design: .rounded))
                            .foregroundColor(Color("PastelBlue"))
                        + Text(" sleeping")
                            .font(.system(size: 17, weight: .regular, design: .rounded))
                            .foregroundColor(.white)
                    )
                    .multilineTextAlignment(.center)
                    .offset(x: -geo.size.width * 0.4, y: geo.size.width*0.025)
                    Text("experience.")
                        .font(.system(size: 17, weight: .regular, design: .rounded))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .offset(x: -geo.size.width * 0.4, y: geo.size.width * 0.00001)
                    
                    Button(action: {
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.1)) {
                            didStart = true
                        }
                    }) {
                        ZStack {
                            Circle()
                                .fill(Color("PastelBlue"))
                                .frame(width: 48, height: 48)
                                .shadow(color: Color("White").opacity(0.18), radius: 8, x: 0, y: 4)
                            Image(systemName: "arrow.right")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(Color("MidnightBlue"))
                        }
                    }
                    .offset(x: -geo.size.width * 0.4)
                }
                .frame(width: geo.size.width, height: geo.size.height, alignment: .bottom)
                .padding(.bottom, geo.size.height * 0.12)
            }
        }
    }
}

struct ConstellationView: View {
    var body: some View {
        ZStack {
            // Lines
            Path { path in
                path.move(to: CGPoint(x: 20, y: 80))
                path.addLine(to: CGPoint(x: 60, y: 60))
                path.addLine(to: CGPoint(x: 100, y: 70))
                path.addLine(to: CGPoint(x: 140, y: 50))
                path.addLine(to: CGPoint(x: 180, y: 60))
                path.addLine(to: CGPoint(x: 220, y: 40))
                path.addLine(to: CGPoint(x: 260, y: 60))
                path.addLine(to: CGPoint(x: 300, y: 80))
            }
            .stroke(Color.white.opacity(0.7), style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
            
            // Stars
            ForEach([CGPoint(x: 20, y: 80), CGPoint(x: 60, y: 60), CGPoint(x: 100, y: 70), CGPoint(x: 140, y: 50), CGPoint(x: 180, y: 60), CGPoint(x: 220, y: 40), CGPoint(x: 260, y: 60), CGPoint(x: 300, y: 80)], id: \.self) { point in
                Circle()
                    .fill(Color.white)
                    .frame(width: 12, height: 12)
                    .position(point)
                    .shadow(color: Color("PastelBlue").opacity(0.5), radius: 6, x: 0, y: 2)
            }
        }
    }
}

// Add these colors to your Assets.xcassets:
// - MidnightBlue: #0A2342
// - DeepBlue: #1B3358
// - PastelBlue: #A7C7E7
// - PastelPurple: #C3B1E1
