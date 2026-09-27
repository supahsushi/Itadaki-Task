import SwiftUI

struct CollectionScreen: View {
    var characters: [CollectionCharacter]

    @Environment(\.dismiss) private var dismiss
    @State private var selectedCharacter: CollectionCharacter?

    private let columns = [
        GridItem(.adaptive(minimum: 124), spacing: 14)
    ]

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(characters) { character in
                        Button {
                            guard character.isUnlocked else { return }
                            selectedCharacter = character
                        } label: {
                            CollectionCharacterCell(character: character)
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(accessibilityLabel(for: character))
                    }
                }
                .padding(18)
            }
            .background(Color(red: 0.98, green: 0.91, blue: 0.80))
            .navigationTitle("Collection")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.light, for: .navigationBar)
            .toolbarBackground(Color(red: 0.98, green: 0.91, blue: 0.80), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .font(.system(size: 17, weight: .black, design: .rounded))
                    .foregroundStyle(Color(red: 0.11, green: 0.08, blue: 0.05))
                }
            }
            .sheet(item: $selectedCharacter) { character in
                CollectionCharacterProfileView(character: character)
                    .presentationDetents([.large])
                    .presentationBackground(Color(red: 0.98, green: 0.91, blue: 0.80))
            }
        }
        .preferredColorScheme(.light)
    }

    private func accessibilityLabel(for character: CollectionCharacter) -> String {
        character.isUnlocked ? "\(character.name), \(character.role)" : "Locked collection character"
    }
}

struct CollectionCharacterCell: View {
    var character: CollectionCharacter

    var body: some View {
        VStack(spacing: 9) {
            ZStack {
                if character.isUnlocked {
                    CollectionCharacterArtwork(character: character)
                        .frame(width: 96, height: 96)
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                } else {
                    RoundedRectangle(cornerRadius: 18)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.45, green: 0.36, blue: 0.30),
                                    Color(red: 0.22, green: 0.16, blue: 0.13)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: 96, height: 96)
                    Image(systemName: "person.fill.questionmark")
                        .font(.system(size: 42, weight: .black))
                        .foregroundStyle(.white.opacity(0.50))
                    Image(systemName: "lock.fill")
                        .font(.system(size: 19, weight: .black))
                        .foregroundStyle(.white)
                        .padding(8)
                        .background(Circle().fill(Color.black.opacity(0.38)))
                        .offset(x: 34, y: 34)
                }
            }
            .frame(width: 104, height: 104)

            VStack(spacing: 3) {
                Text(character.isUnlocked ? character.name : "???")
                    .font(.system(size: 14, weight: .black, design: .rounded))
                    .foregroundStyle(Color(red: 0.12, green: 0.08, blue: 0.06))
                    .lineLimit(1)
                    .minimumScaleFactor(0.76)

                Text(character.isUnlocked ? character.role : "Not met yet")
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundStyle(Color(red: 0.44, green: 0.31, blue: 0.22))
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
            }
        }
        .padding(11)
        .frame(maxWidth: .infinity)
        .background(Color.white.opacity(0.72), in: RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color(red: 0.74, green: 0.42, blue: 0.22).opacity(0.28), lineWidth: 1)
        )
    }
}

struct CollectionCharacterArtwork: View {
    var character: CollectionCharacter

    var body: some View {
        if UIImage(named: character.artworkAssetName) != nil {
            Image(character.artworkAssetName)
                .resizable()
                .scaledToFill()
        } else {
            ZStack {
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color(red: 0.86, green: 0.58, blue: 0.38).gradient)
                Image(systemName: "person.crop.square.fill")
                    .font(.system(size: 44, weight: .black))
                    .foregroundStyle(.white.opacity(0.86))
            }
        }
    }
}

struct CollectionCharacterProfileView: View {
    var character: CollectionCharacter

    private var ink: Color {
        Color(red: 0.13, green: 0.08, blue: 0.05)
    }

    private var softInk: Color {
        Color(red: 0.42, green: 0.31, blue: 0.23)
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {
                CollectionCharacterArtwork(character: character)
                    .frame(width: 180, height: 180)
                    .clipShape(RoundedRectangle(cornerRadius: 24))
                    .shadow(color: .black.opacity(0.18), radius: 12, y: 8)

                VStack(spacing: 5) {
                    Text(character.name)
                        .font(.system(size: 30, weight: .black, design: .rounded))
                        .foregroundStyle(ink)
                        .multilineTextAlignment(.center)

                    Text(character.role)
                        .font(.system(size: 17, weight: .black, design: .rounded))
                        .foregroundStyle(Color(red: 0.90, green: 0.20, blue: 0.38))
                        .multilineTextAlignment(.center)
                }

                VStack(alignment: .leading, spacing: 12) {
                    profileSection("About", character.about)
                    profileSection("Personality", character.personality)
                    profileSection("Loves", character.loves)
                    profileSection("Fun Fact", character.funFact)
                    profileSection("Met On", metOnText)
                }
                .padding(15)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.white.opacity(0.88), in: RoundedRectangle(cornerRadius: 16))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color(red: 0.74, green: 0.42, blue: 0.22).opacity(0.22), lineWidth: 1)
                )
            }
            .padding(22)
        }
        .background(Color(red: 0.98, green: 0.91, blue: 0.80))
        .preferredColorScheme(.light)
    }

    private var metOnText: String {
        guard let date = character.dateFirstMet else { return "Not met yet" }
        return date.formatted(date: .abbreviated, time: .omitted)
    }

    private func profileSection(_ title: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(title.uppercased())
                .font(.system(size: 10, weight: .black, design: .rounded))
                .foregroundStyle(softInk)
            Text(value)
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundStyle(ink)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}
