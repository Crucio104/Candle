import SwiftUI

public struct AvatarCircleView: View {
    public let avatarData: Data?
    public let initials: String
    public let colorIndex: Int
    public let size: CGFloat
    
    public init(avatarData: Data?, initials: String, colorIndex: Int, size: CGFloat = 48) {
        self.avatarData = avatarData
        self.initials = initials
        self.colorIndex = colorIndex
        self.size = size
    }
    
    public init(person: BirthdayPerson, size: CGFloat = 48) {
        self.avatarData = person.avatarImageData
        self.initials = person.initials
        self.colorIndex = person.colorIndex
        self.size = size
    }
    
    public var body: some View {
        ZStack {
            if let avatarData = avatarData, let uiImage = UIImage(data: avatarData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: size, height: size)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(CandleTheme.avatarPrimaryColor(for: colorIndex).opacity(0.6), lineWidth: 2)
                    )
                    .shadow(color: CandleTheme.avatarPrimaryColor(for: colorIndex).opacity(0.2), radius: 4, x: 0, y: 2)
            } else {
                let gradient = CandleTheme.avatarGradient(for: colorIndex)
                Circle()
                    .fill(gradient)
                    .frame(width: size, height: size)
                    .overlay(
                        Circle()
                            .stroke(CandleTheme.avatarPrimaryColor(for: colorIndex).opacity(0.3), lineWidth: 1.5)
                    )
                    .overlay(
                        Group {
                            if initials.isEmpty {
                                Image(systemName: "person.fill")
                                    .font(.system(size: size * 0.42))
                                    .foregroundColor(.white.opacity(0.9))
                            } else {
                                Text(initials)
                                    .font(.system(size: size * 0.38, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                            }
                        }
                    )
                    .shadow(color: CandleTheme.avatarPrimaryColor(for: colorIndex).opacity(0.25), radius: 4, x: 0, y: 2)
            }
        }
    }
}
