import UIKit

// Модель данных для работы с API
struct Hero: Codable {
    let id: Int
    let name: String
    let powerstats: Powerstats
    let appearance: Appearance
    let biography: Biography
    let work: Work
    let connections: Connections
    let images: Images
}

struct Powerstats: Codable {
    let intelligence: Int
    let strength: Int
    let speed: Int
    let durability: Int
    let power: Int
    let combat: Int
}

struct Appearance: Codable {
    let gender: String
    let race: String?
    let height: [String]
    let weight: [String]
    let eyeColor: String
    let hairColor: String
}

struct Biography: Codable {
    let fullName: String?
    let placeOfBirth: String?
    let firstAppearance: String?
    let publisher: String?
    let alignment: String?
}

struct Work: Codable {
    let occupation: String?
    let base: String?
}

struct Connections: Codable {
    let groupAffiliation: String?
    let relatives: String?
}

struct Images: Codable {
    let lg: String
}

class ViewController: UIViewController {
    // Привязка элементов со сториборда
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var heroImageView: UIImageView!
    @IBOutlet weak var statslabel: UILabel!
    @IBOutlet weak var biolabel: UILabel!
    
    

    var allHeroes: [Hero] = [] // Массив всех героев из API

    override func viewDidLoad() {
        super.viewDidLoad()
        fetchAllHeroes()
    }

    // Загрузка данных с API
    func fetchAllHeroes() {
        guard let url = URL(string: "https://akabab.github.io/superhero-api/api/all.json") else {
            print("Неверный URL")
            return
        }

        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            if let error = error {
                print("Ошибка загрузки данных: \(error.localizedDescription)")
                return
            }

            guard let data = data else {
                print("Данные не получены")
                return
            }

            do {
                let decodedHeroes = try JSONDecoder().decode([Hero].self, from: data)
                DispatchQueue.main.async {
                    self?.allHeroes = decodedHeroes
                    self?.showRandomHero()
                }
            } catch {
                print("Ошибка парсинга JSON: \(error.localizedDescription)")
            }
        }.resume()
    }
    func showRandomHero() {
            guard !allHeroes.isEmpty else {
                print("Список героев пуст")
                return
            }

            let randomHero = allHeroes.randomElement()!
            nameLabel.text = randomHero.name
            statslabel.text = """
            Intelligence: \(randomHero.powerstats.intelligence)
            Strength: \(randomHero.powerstats.strength)
            Speed: \(randomHero.powerstats.speed)
            Durability: \(randomHero.powerstats.durability)
            Power: \(randomHero.powerstats.power)
            Combat: \(randomHero.powerstats.combat)
            """
            biolabel.text = """
            Full Name: \(randomHero.biography.fullName ?? "Unknown")
            Place of Birth: \(randomHero.biography.placeOfBirth ?? "Unknown")
            First Appearance: \(randomHero.biography.firstAppearance ?? "Unknown")
            Publisher: \(randomHero.biography.publisher ?? "Unknown")
            """
            if let imageUrl = URL(string: randomHero.images.lg) {
                heroImageView.downloadImage(from: imageUrl)
            }
        }

        // Привязка кнопки "Randomize"
        @IBAction func randomizeHero(_ sender: UIButton) {
            showRandomHero()
        }
    }

    // Расширение для загрузки изображения
    extension UIImageView {
        func downloadImage(from url: URL) {
            URLSession.shared.dataTask(with: url) { data, _, error in
                if let error = error {
                    print("Ошибка загрузки изображения: \(error.localizedDescription)")
                    return
                }

                guard let data = data, let image = UIImage(data: data) else {
                    print("Ошибка обработки данных изображения")
                    return
                }

                DispatchQueue.main.async {
                    self.image = image
                }
            }.resume()
        }
    }
