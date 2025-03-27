import Foundation

// Точка
struct Point {
    let x: Double
    let y: Double
    
    func distance(to point: Point) -> Double {
        return sqrt(pow(point.x - x, 2) + pow(point.y - y, 2))
    }
}

// Вектор
struct Vector {
    let dx: Double
    let dy: Double
    
    var magnitude: Double {
        return sqrt(dx*dx + dy*dy)
    }
    
    func dotProduct(with vector: Vector) -> Double {
        return dx * vector.dx + dy * vector.dy
    }
    
    func angle(with vector: Vector) -> Double {
        let dot = dotProduct(with: vector)
        let magnitudes = magnitude * vector.magnitude
        return acos(dot / magnitudes) * 180 / Double.pi // у градусах
    }
}

// Базовий клас фігури
class Shape {
    let points: [Point]
    var name: String
    
    init(points: [Point], name: String = "невідома") {
        self.points = points
        self.name = name
    }
    
    var perimeter: Double {
        return 0
    }
    
    var area: Double {
        return 0
    }
}

// Лінія
class Line: Shape {
    var start: Point { return points[0] }
    var end: Point { return points[1] }
    var vector: Vector { return Vector(dx: end.x - start.x, dy: end.y - start.y) }
    
    init(start: Point, end: Point) {
        super.init(points: [start, end], name: "лінія")
    }
    
    override var perimeter: Double {
        return start.distance(to: end)
    }
    
    func angle(with line: Line) -> Double {
        return vector.angle(with: line.vector)
    }
}

// Трикутник
class Triangle: Shape {
    enum AngleType {
        case acute, right, obtuse
    }
    
    enum SideType {
        case equilateral, isosceles, scalene
    }
    
    var a: Point { return points[0] }
    var b: Point { return points[1] }
    var c: Point { return points[2] }
    
    var ab: Double { return a.distance(to: b) }
    var bc: Double { return b.distance(to: c) }
    var ca: Double { return c.distance(to: a) }
    
    var angleType: AngleType {
        let sides = [ab, bc, ca].sorted()
        let a2 = pow(sides[0], 2)
        let b2 = pow(sides[1], 2)
        let c2 = pow(sides[2], 2)
        
        if a2 + b2 > c2 { return .acute }
        if a2 + b2 == c2 { return .right }
        return .obtuse
    }
    
    var sideType: SideType {
        if ab == bc && bc == ca { return .equilateral }
        if ab == bc || bc == ca || ca == ab { return .isosceles }
        return .scalene
    }
    
    init(a: Point, b: Point, c: Point) {
        super.init(points: [a, b, c], name: "трикутник")
    }
    
    override var perimeter: Double {
        return ab + bc + ca
    }
    
    override var area: Double {
        let s = perimeter / 2
        return sqrt(s * (s - ab) * (s - bc) * (s - ca))
    }
}

// Чотирикутник
class Quadrilateral: Shape {
    enum QuadType {
        case rhombus, rectangle, square, other
    }
    
    var a: Point { return points[0] }
    var b: Point { return points[1] }
    var c: Point { return points[2] }
    var d: Point { return points[3] }
    
    var ab: Double { return a.distance(to: b) }
    var bc: Double { return b.distance(to: c) }
    var cd: Double { return c.distance(to: d) }
    var da: Double { return d.distance(to: a) }
    
    var type: QuadType {
        let sides = [ab, bc, cd, da]
        let diagonals = [a.distance(to: c), b.distance(to: d)]
        
        // Перевірка на квадрат
        if sides.allSatisfy({ $0 == ab }) && diagonals[0] == diagonals[1] {
            return .square
        }
        
        // Перевірка на ромб
        if sides.allSatisfy({ $0 == ab }) {
            return .rhombus
        }
        
        // Перевірка на прямокутник
        if ab == cd && bc == da && diagonals[0] == diagonals[1] {
            return .rectangle
        }
        
        return .other
    }
    
    init(a: Point, b: Point, c: Point, d: Point) {
        super.init(points: [a, b, c, d], name: "чотирикутник")
    }
    
    override var perimeter: Double {
        return ab + bc + cd + da
    }
    
    override var area: Double {
        // Формула площі Гаусса для чотирикутника
        let p = points
        return 0.5 * abs((p[0].x*p[1].y + p[1].x*p[2].y + p[2].x*p[3].y + p[3].x*p[0].y) -
                         (p[0].y*p[1].x + p[1].y*p[2].x + p[2].y*p[3].x + p[3].y*p[0].x))
    }
}

// Ромб
class Rhombus: Quadrilateral {
    init(center: Point, width: Double, height: Double) {
        let a = Point(x: center.x, y: center.y + height/2)
        let b = Point(x: center.x + width/2, y: center.y)
        let c = Point(x: center.x, y: center.y - height/2)
        let d = Point(x: center.x - width/2, y: center.y)
        super.init(a: a, b: b, c: c, d: d)
        name = "ромб"
    }
}

// Прямокутник
class Rectangle: Quadrilateral {
    init(origin: Point, width: Double, height: Double) {
        let a = origin
        let b = Point(x: origin.x + width, y: origin.y)
        let c = Point(x: origin.x + width, y: origin.y + height)
        let d = Point(x: origin.x, y: origin.y + height)
        super.init(a: a, b: b, c: c, d: d)
        name = "прямокутник"
    }
}

// Квадрат
class Square: Rectangle {
    init(origin: Point, side: Double) {
        super.init(origin: origin, width: side, height: side)
        name = "квадрат"
    }
}

// Клас для роботи з фігурами
class Mathematics {
    private var shapes: [Shape] = []
    
    func addShape(_ shape: Shape) {
        shapes.append(shape)
    }
    
    func printMinMax() {
        guard !shapes.isEmpty else {
            print("Немає фігур для аналізу")
            return
        }
        
        let minAreaShape = shapes.min(by: { $0.area < $1.area })!
        let maxAreaShape = shapes.max(by: { $0.area < $1.area })!
        let minPerimeterShape = shapes.min(by: { $0.perimeter < $1.perimeter })!
        let maxPerimeterShape = shapes.max(by: { $0.perimeter < $1.perimeter })!
        
        print("Фігура з найменшою площею: \(minAreaShape.name) (\(minAreaShape.area))")
        print("Фігура з найбільшою площею: \(maxAreaShape.name) (\(maxAreaShape.area))")
        print("Фігура з найменшим периметром: \(minPerimeterShape.name) (\(minPerimeterShape.perimeter))")
        print("Фігура з найбільшим периметром: \(maxPerimeterShape.name) (\(maxPerimeterShape.perimeter))")
    }
}

// Приклад використання
let math = Mathematics()

// Створення фігур
let line = Line(start: Point(x: 0, y: 0), end: Point(x: 3, y: 0))
let triangle = Triangle(a: Point(x: 0, y: 0), b: Point(x: 3, y: 0), c: Point(x: 0, y: 4))
let quad = Quadrilateral(a: Point(x: 0, y: 0), b: Point(x: 4, y: 0), 
                        c: Point(x: 4, y: 3), d: Point(x: 0, y: 3))
let rhombus = Rhombus(center: Point(x: 0, y: 0), width: 4, height: 2)
let rectangle = Rectangle(origin: Point(x: 0, y: 0), width: 5, height: 3)
let square = Square(origin: Point(x: 0, y: 0), side: 4)

// Додавання фігур
math.addShape(line)
math.addShape(triangle)
math.addShape(quad)
math.addShape(rhombus)
math.addShape(rectangle)
math.addShape(square)

// Аналіз фігур
math.printMinMax()

// Додаткові приклади роботи з фігурами
print("\nДодаткова інформація:")
print("Тип трикутника за кутами: \(triangle.angleType)")
print("Тип трикутника за сторонами: \(triangle.sideType)")
print("Тип чотирикутника: \(quad.type)")
print("Кут між лініями: \(line.angle(with: Line(start: Point(x: 0, y: 0), end: Point(x: 1, y: 1))))°")
