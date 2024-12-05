import UIKit
import Alamofire
import Kingfisher

// Модель данных для работы с API
struct Hero: Codable {
    let id: Int
    let name: String
    let powerstats: Powerstats
    let biography: Biography
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

struct Biography: Codable {
    let fullName: String?
    let placeOfBirth: String?
    let firstAppearance: String?
    let publisher: String?
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

        // Загрузка данных с использованием Alamofire
        func fetchAllHeroes() {
            let url = "https://akabab.github.io/superhero-api/api/all.json"
            
            AF.request(url).validate().responseDecodable(of: [Hero].self) { response in
                switch response.result {
                case .success(let heroes):
                    DispatchQueue.main.async {
                        self.allHeroes = heroes
                        self.showRandomHero()
                    }
                case .failure(let error):
                    print("Ошибка загрузки данных: \(error.localizedDescription)")
                }
            }
        }

        // Показ случайного героя
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
                // Используем Kingfisher для загрузки изображения
                heroImageView.kf.setImage(with: imageUrl)
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
