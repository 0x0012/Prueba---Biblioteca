-- Prueba - Biblioteca
-- @ Max Coronado Lorca

-- 1. Crear base de datos y tablas
CREATE DATABASE biblioteca;

CREATE TABLE Tipo_Autor (
	id_tipo SERIAL,
	tipo VARCHAR(10) NOT NULL,
	PRIMARY KEY (id_tipo)
);

CREATE TABLE Autores (
	codigo_autor SERIAL,
	nombre VARCHAR(20) NOT NULL,
	apellido VARCHAR(20) NOT NULL,
	nacimiento INT NOT NULL,
	muerte INT,
	id_tipo INT NOT NULL,
	FOREIGN KEY (id_tipo) REFERENCES Tipo_Autor(id_tipo),
	PRIMARY KEY (codigo_autor)
);

CREATE TABLE Libros (
	isbn VARCHAR(15),
	titulo VARCHAR(30) NOT NULL,
	paginas INT,
	codigo_autor INT NOT NULL,
	codigo_coautor INT,
	FOREIGN KEY (codigo_autor) REFERENCES Autores(codigo_autor),
	FOREIGN KEY (codigo_coautor) REFERENCES Autores(codigo_autor),
	PRIMARY KEY (isbn)
);

CREATE TABLE Ciudades (
	id SERIAL,
	nombre VARCHAR(30),
	PRIMARY KEY (id)
);

CREATE TABLE Socios (
	rut VARCHAR(10),
	nombre VARCHAR(20) NOT NULL,
	apellido VARCHAR(20) NOT NULL,
	direccion VARCHAR(50) NOT NULL,
	id_ciudad INT NOT NULL,
	telefono INT NOT NULL,
	FOREIGN KEY (id_ciudad) REFERENCES Ciudades(id),
	PRIMARY KEY (rut)
);

CREATE TABLE Prestamos (
	id SERIAL,
	id_socio VARCHAR(10) NOT NULL,
	id_libro VARCHAR(15) NOT NULL,
	fecha_prestamo DATE NOT NULL,
	fecha_devolucion DATE,
	FOREIGN KEY (id_socio) REFERENCES Socios(rut),
	FOREIGN KEY (id_libro) REFERENCES Libros(isbn),
	PRIMARY KEY (id)
);

-- 2. Insertar datos
INSERT INTO Tipo_autor (tipo)
	VALUES
		('PRINCIPAL'),
		('COAUTOR');

INSERT INTO Autores (nombre, apellido, nacimiento, muerte, id_tipo)
	VALUES
		('ANDRÉS', 'ULLOA', 1982, NULL, 1),
		('SERGIO', 'MARDONES', 1950, 2012, 1),
		('JOSE', 'SALGADO', 1968, 2020, 1),
		('ANA', 'SALGADO', 1972, NULL, 2),
		('MARTIN', 'PORTA', 1976, NULL, 1);

INSERT INTO Libros (isbn, titulo, paginas, codigo_autor, codigo_coautor)
	VALUES
		('111-1111111-111', 'CUENTOS DE TERROR', 344, 3, 4),
		('222-2222222-222', 'POESÍAS CONTEMPORANEAS', 167, 1, NULL),
		('333-3333333-333', 'HISTORIA DE ASIA', 511, 2, NULL),
		('444-4444444-444', 'MANUAL DE MECÁNICA', 298, 5, NULL);

INSERT INTO Ciudades (nombre)
	VALUES
		('SANTIAGO');

INSERT INTO Socios (rut, nombre, apellido, direccion, id_ciudad, telefono)
	VALUES
		('1111111-1', 'JUAN', 'SOTO', 'AVENIDA 1', 1, 911111111),
		('2222222-2', 'ANA', 'PÉREZ', 'PASAJE 2', 1, 922222222),
		('3333333-3', 'SANDRA', 'AGUILAR', 'AVENIDA 2', 1, 933333333),
		('4444444-4', 'ESTEBAN', 'JEREZ', 'AVENIDA 3', 1, 944444444),
		('5555555-5', 'SILVANA', 'MUÑOZ', 'PASAJE 3', 1, 955555555);

INSERT INTO Prestamos (id_socio, id_libro, fecha_prestamo, fecha_devolucion)
	VALUES
		('1111111-1', '111-1111111-111', '20-01-2020', '27-01-2020'),
		('5555555-5', '222-2222222-222', '20-01-2020', '30-01-2020'),
		('3333333-3', '333-3333333-333', '22-01-2020', '30-01-2020'),
		('4444444-4', '444-4444444-444', '23-01-2020', '30-01-2020'),
		('2222222-2', '111-1111111-111', '27-01-2020', '04-02-2020'),
		('1111111-1', '444-4444444-444', '31-01-2020', '12-02-2020'),
		('3333333-3', '222-2222222-222', '31-01-2020', '12-02-2020');

-- 3. Consultas
-- a. Mostrar todos los libros que posean menos de 300 páginas.
SELECT titulo, paginas from Libros WHERE paginas < 300;

-- b. Mostrar todos los autores que hayan nacido después del 01-01-1970.
SELECT nombre, nacimiento FROM Autores WHERE nacimiento >= 1970;

-- c. ¿Cuál es el libro más solicitado?
SELECT l.titulo AS titulo, p.count AS pedido FROM  Libros l
	INNER JOIN (
		SELECT COUNT(id_libro), id_libro FROM Prestamos GROUP BY id_libro ORDER BY count DESC LIMIT 1
	) p
	ON l.isbn = p.id_libro;

-- d. Si se cobrara una multa de $100 por cada día de atraso, mostrar cuánto debería pagar cada usuario que entregue el préstamo después de 7 días.
SELECT s.rut AS RUT, s.nombre AS nombre, s.apellido AS apellido, SUM(p.fecha_devolucion - p.fecha_prestamo - 7) as atraso, SUM(p.fecha_devolucion - p.fecha_prestamo - 7) * 100 as deuda
	FROM Socios s
	INNER JOIN Prestamos p ON p.id_socio = s.rut
	WHERE p.fecha_devolucion - p.fecha_prestamo > 7
	GROUP BY s.rut
	ORDER BY s.apellido;