-- ------------------------------------------------------------
-- SCRIPT DE INSERCIÓN DE DATOS DE PRUEBA INICIALES - CORREGIDO
-- ------------------------------------------------------------

-- PASO 0: DESHABILITAR VERIFICACIÓN DE CLAVES FORÁNEAS
SET FOREIGN_KEY_CHECKS = 0;

-- RESETEAR AUTO_INCREMENT
ALTER TABLE usuarios AUTO_INCREMENT = 1;
ALTER TABLE proyectos AUTO_INCREMENT = 1;
ALTER TABLE dispositivos AUTO_INCREMENT = 1;
ALTER TABLE sensores AUTO_INCREMENT = 1;
ALTER TABLE campos_sensores AUTO_INCREMENT = 1;
ALTER TABLE valores AUTO_INCREMENT = 1;
ALTER TABLE roles AUTO_INCREMENT = 1;
ALTER TABLE unidades_medida AUTO_INCREMENT = 1;
ALTER TABLE permisos AUTO_INCREMENT = 1;
ALTER TABLE proyecto_usuarios AUTO_INCREMENT = 1;
ALTER TABLE recibos_energia AUTO_INCREMENT = 1;

-- ************************************************************
-- INSERCIÓN DE DATOS BASE (ROLES, PERMISOS Y UNIDADES)
-- ************************************************************

-- ROLES DEL SISTEMA
INSERT INTO roles (nombre_rol, descripcion) VALUES
('Administrador', 'Control total del sistema'),
('Propietario', 'Dueño del proyecto con permisos de gestión'),
('Observador', 'Puede ver datos, pero no modificar configuraciones'),
('Colaborador', 'Puede modificar y crear sensores/datos en proyectos invitados');

-- PERMISOS DEL SISTEMA (Corregidos)
INSERT INTO permisos (id, nombre_permiso, descripcion) VALUES
(1, 'GESTION_USUARIOS_SISTEMA', 'Permite el control total de las cuentas de usuario (Solo Admin)'),
(2, 'CRUD_PROYECTO_PROPIO', 'Permite modificar y eliminar proyectos PROPIOS'),
(3, 'CREAR_PROYECTO', 'Permite crear nuevos proyectos'),
(4, 'GESTIONAR_ACCESO_PROYECTO', 'Permite invitar y remover usuarios de un proyecto'),
(5, 'CRUD_HARDWARE', 'Permite crear/modificar/eliminar Dispositivos, Sensores y Campos'),
(6, 'VER_DATOS_IOT', 'Permite ver Reportes Históricos y Gráficos en Tiempo Real'),
(7, 'GESTIONAR_LOTES_ENERGIA', 'Permite cargar y eliminar lotes de CSV de energía'),
(8, 'VER_ANALISIS_ENERGIA', 'Permite ver los dashboards de Análisis Energético y Simulaciones');

-- ASIGNACIÓN DE PERMISOS A ROLES (Corregida)
INSERT INTO rol_permisos (rol_id, permiso_id) VALUES
-- 1: Administrador (Control Total del Sistema)
(1, 1), (1, 2), (1, 3), (1, 4), (1, 5), (1, 6), (1, 7), (1, 8),

-- 2: Propietario (Dueño del Proyecto: Puede hacer todo DENTRO del proyecto)
(2, 2), -- CRUD Proyecto Propio
(2, 3), -- Crear Proyecto
(2, 4), -- Gestionar Acceso
(2, 5), -- CRUD Hardware
(2, 6), -- Ver Datos IoT
(2, 7), -- Gestionar Lotes
(2, 8), -- Ver Análisis Energía

-- 3: Observador (Invitado: Solo Ver)
(3, 6), -- Ver Datos IoT
(3, 8), -- Ver Análisis Energía

-- 4: Colaborador (Invitado: Ver y Editar Hardware)
(4, 5), -- CRUD Hardware
(4, 6), -- Ver Datos IoT
(4, 8); -- Ver Análisis Energía
-- UNIDADES DE MEDIDA
INSERT INTO unidades_medida (nombre, simbolo, descripcion, magnitud_tipo) VALUES
('Celsius', '°C', 'Temperatura en grados Celsius', 'Temperatura'),
('Humedad Relativa', '%', 'Porcentaje de humedad', 'Humedad'),
('Voltios', 'V', 'Tensión eléctrica', 'Electricidad'),
('Lux', 'lx', 'Intensidad de iluminación', 'Iluminación'),
('Kilowatt-hora', 'kWh', 'Consumo de energía eléctrica', 'Energía'),
('Watts', 'W', 'Potencia eléctrica', 'Potencia'),
('Booleano (Estado)', 'bool', 'Estado binario (0/1, On/Off)', 'Estado'),
('Segundo', 's', 'Unidad de tiempo', 'Tiempo'),
('HectoPascales', 'hPa', 'Presión atmosférica', 'Presión'),
('Metros', 'm', 'Distancia o longitud', 'Distancia'),
('Partes por millón', 'ppm', 'Concentración de gases o partículas', 'Concentración'),
('Fahrenheit', '°F', 'Temperatura en grados Fahrenheit', 'Temperatura'),
('Amperios', 'A', 'Corriente eléctrica (Intensidad)', 'Electricidad'),
('Miliamperios', 'mA', 'Corriente eléctrica (Intensidad)', 'Electricidad'),
('Pascales', 'Pa', 'Presión (Unidad SI)', 'Presión'),
('Bar', 'bar', 'Unidad de presión (1 bar ≈ 1 atm)', 'Presión'),
('Centímetros', 'cm', 'Distancia o longitud (para sensores ultrasónicos)', 'Distancia'),
('Gramos', 'g', 'Masa o peso', 'Masa'),
('Kilogramos', 'kg', 'Masa o peso', 'Masa'),
('Litros', 'L', 'Volumen de líquidos', 'Volumen'),
('Litros por minuto', 'L/min', 'Caudal o flujo de líquido', 'Flujo'),
('Decibelios', 'dB', 'Nivel de intensidad de sonido', 'Sonido'),
('Hertz', 'Hz', 'Frecuencia', 'Frecuencia'),
('Minuto', 'min', 'Unidad de tiempo', 'Tiempo'),
('Grados (Angulo)', '°', 'Medida angular (para servos, giroscopios)', 'Angulo'),
('Conteo (Unidad)', 'N/A', 'Para conteo de eventos o ítems (ej. pulsos)', 'Conteo'),
('Grados por segundo', '°/s', 'Velocidad angular (Usada en Giroscopios)', 'Velocidad Angular'),
('Kilómetros por hora', 'km/h', 'Velocidad lineal (Viento o vehicular)', 'Velocidad'),
('Metros por segundo', 'm/s', 'Velocidad lineal (Unidad SI)', 'Velocidad'),
('pH', 'pH', 'Nivel de acidez o alcalinidad (Calidad de agua/suelo)', 'pH'),
('Newton', 'N', 'Medida de fuerza (Usada en celdas de carga)', 'Fuerza'),
('Índice Ultravioleta', 'Índice UV', 'Intensidad de radiación solar UV', 'Radiación'),
('Factor de Potencia', 'PF', 'Eficiencia eléctrica (Adimensional, cos(φ))', 'Factor de Potencia');



-- ************************************************************
-- INSERCIÓN DE USUARIOS Y PROYECTOS DE PRUEBA
-- ************************************************************

-- USUARIOS DE PRUEBA (contraseña: "testpass" hasheada con bcrypt)
INSERT INTO usuarios (nombre_usuario, nombre, apellido, email, contrasena, activo, fecha_registro, ultimo_login) VALUES
('admin_user', 'Iván', 'Góngora', 'ivan@ejemplo.com', '$2b$12$4pOr6.S0V9pC.I0tfkbFxuujiYLR0/5IjgU.nKj3Cwo2O5QenY2ki', TRUE, NOW(), NOW()),
('colaborador', 'Ana', 'Pérez', 'ana@ejemplo.com', '$2b$12$4pOr6.S0V9pC.I0tfkbFxuujiYLR0/5IjgU.nKj3Cwo2O5QenY2ki', TRUE, NOW(), NULL),
('observador', 'Roger', 'Smith', 'roger@ejemplo.com', '$2b$12$4pOr6.S0V9pC.I0tfkbFxuujiYLR0/5IjgU.nKj3Cwo2O5QenY2ki', TRUE, NOW(), NULL);

-- PROYECTOS DE PRUEBA
INSERT INTO proyectos (nombre, descripcion, usuario_id, tipo_industria) VALUES
('Invernadero Principal', 'Monitoreo de temperatura y humedad para el cultivo de tomates', 1, 'Agricultura Precision'),
('Estación Meteorológica', 'Recolección de datos ambientales generales en el tejado', 1, 'Monitoreo Ambiental');

-- ASIGNACIÓN DE USUARIOS A PROYECTOS
INSERT INTO proyecto_usuarios (proyecto_id, usuario_id, rol_id) VALUES
(1, 1, 2), -- Iván como Propietario del Proyecto 1
(1, 2, 4), -- Ana como Colaborador del Proyecto 1
(2, 1, 2); -- Iván como Propietario del Proyecto 2

-- DISPOSITIVOS DE PRUEBA
INSERT INTO dispositivos (nombre, descripcion, tipo, latitud, longitud, habilitado, fecha_creacion, proyecto_id) VALUES
('NodeMCU Zona Norte', 'Dispositivo ESP8266 para medir condiciones cerca de la puerta', 'Microcontrolador', 20.5, -87.0, TRUE, NOW(), 1),
('Estación Exterior', 'Dispositivo principal para datos exteriores', 'Raspberry Pi', 20.501, -87.001, TRUE, NOW(), 2);

-- SEGUNDO: INSERTAR SENSORES
INSERT INTO sensores (nombre, tipo, fecha_creacion, habilitado, dispositivo_id) VALUES
('DHT22', 'Temperatura/Humedad', NOW(), TRUE, 1),
('SCT-013-000', 'Energía/Corriente/Potencia', NOW(), TRUE, 1),
('BH1750', 'Iluminación', NOW(), TRUE, 1),
('PIR HC-SR501', 'Movimiento', NOW(), TRUE, 1);

-- TERCERO: INSERTAR CAMPOS_SENSORES (con IDs correctos de unidades_medida)
INSERT INTO campos_sensores (nombre, tipo_valor, sensor_id, unidad_medida_id) VALUES
('Temperatura', 'Float', (SELECT id FROM sensores WHERE nombre = 'DHT22'), (SELECT id FROM unidades_medida WHERE nombre = 'Celsius')),
('Humedad', 'Float', (SELECT id FROM sensores WHERE nombre = 'DHT22'), (SELECT id FROM unidades_medida WHERE nombre = 'Humedad Relativa')),
('Energia', 'Float', (SELECT id FROM sensores WHERE nombre = 'SCT-013-000'), (SELECT id FROM unidades_medida WHERE nombre = 'Kilowatt-hora')),
('Corriente', 'Float', (SELECT id FROM sensores WHERE nombre = 'SCT-013-000'), (SELECT id FROM unidades_medida WHERE nombre = 'Amperios')),
('Potencia', 'Float', (SELECT id FROM sensores WHERE nombre = 'SCT-013-000'), (SELECT id FROM unidades_medida WHERE nombre = 'Watts')),
('Iluminacion', 'Integer', (SELECT id FROM sensores WHERE nombre = 'BH1750'), (SELECT id FROM unidades_medida WHERE nombre = 'Lux')),
('Movimiento', 'Integer', (SELECT id FROM sensores WHERE nombre = 'PIR HC-SR501'), (SELECT id FROM unidades_medida WHERE nombre = 'Booleano (Estado)'));

-- CUARTO: INSERTAR VALORES (usando los datos del JSON)
INSERT INTO valores (valor, fecha_hora_lectura, fecha_hora_registro, campo_id) VALUES
(29.500000, NOW(), NOW(), (SELECT id FROM campos_sensores WHERE nombre = 'Temperatura' AND sensor_id = (SELECT id FROM sensores WHERE nombre = 'DHT22-Aire'))),
(87.900000, NOW(), NOW(), (SELECT id FROM campos_sensores WHERE nombre = 'Humedad' AND sensor_id = (SELECT id FROM sensores WHERE nombre = 'DHT22-Aire'))),
(123.700000, NOW(), NOW(), (SELECT id FROM campos_sensores WHERE nombre = 'Energia' AND sensor_id = (SELECT id FROM sensores WHERE nombre = 'SCT-013-000'))),
(23.450000, NOW(), NOW(), (SELECT id FROM campos_sensores WHERE nombre = 'Corriente' AND sensor_id = (SELECT id FROM sensores WHERE nombre = 'SCT-013-000'))),
(245.100000, NOW(), NOW(), (SELECT id FROM campos_sensores WHERE nombre = 'Potencia' AND sensor_id = (SELECT id FROM sensores WHERE nombre = 'SCT-013-000'))),
(684.000000, NOW(), NOW(), (SELECT id FROM campos_sensores WHERE nombre = 'Iluminacion' AND sensor_id = (SELECT id FROM sensores WHERE nombre = 'BH1750'))),
(0.000000, NOW(), NOW(), (SELECT id FROM campos_sensores WHERE nombre = 'Movimiento' AND sensor_id = (SELECT id FROM sensores WHERE nombre = 'PIR HC-SR501')));
-- ************************************************************
-- INSERCIÓN DE DATOS REALES DE RECIBOS DE ENERGÍA
-- ************************************************************

-- DATOS REALES DE RECIBOS DE ENERGÍA (usuario_id = 1, lote_nombre = 'historico_2021')
INSERT INTO recibos_energia (usuario_id, periodo, consumo_total_kwh, demanda_maxima_kw, factor_potencia, costo_total, dias_facturados, tarifa, kwh_punta, lote_nombre) VALUES
(1, '2021-01-31', 29561, 70, 82.88, 83382, 31, 'GDMTH', 4116, 'historico_2021'),
(1, '2021-02-28', 27960, 73, 82.68, 84520, 28, 'GDMTH', 3860, 'historico_2021'),
(1, '2021-03-31', 33493, 79, 84.18, 97037, 31, 'GDMTH', 4469, 'historico_2021'),
(1, '2021-04-30', 33051, 126, NULL, 95215, 30, 'GDMTH', 2271, 'historico_2021'),
(1, '2021-05-31', 36575, 149, 87.39, 99451, 31, 'GDMTH', 1858, 'historico_2021'),
(1, '2021-06-30', 38639, 176, 87.35, 105063, 30, 'GDMTH', 2022, 'historico_2021'),
(1, '2021-07-31', 36969, 150, 87.69, 100381, 31, 'GDMTH', 2057, 'historico_2021'),
(1, '2021-08-31', 40672, 245, 89.45, 110017, 31, 'GDMTH', 2029, 'historico_2021'),
(1, '2021-09-30', 49000, 284, 90.96, 136097, 30, 'GDMTH', 1996, 'historico_2021'),
(1, '2021-10-31', 48804, 272, NULL, 135002, 31, 'GDMTH', 2283, 'historico_2021'),
(1, '2021-11-30', 45743, 220, 88.75, 143294, 30, 'GDMTH', 5684, 'historico_2021'),
(1, '2021-12-31', 46339, 213, 89.91, 142688, 31, 'GDMTH', 6548, 'historico_2021');

-- PASO FINAL: HABILITAR VERIFICACIÓN DE CLAVES FORÁNEAS
SET FOREIGN_KEY_CHECKS = 1;

-- CONFIRMACIÓN DE INSERCIÓN
SELECT 'Datos de prueba insertados exitosamente' AS Estado;
SELECT COUNT(*) as total_usuarios FROM usuarios;
SELECT COUNT(*) as total_recibos FROM recibos_energia;
SELECT COUNT(*) as total_valores FROM valores;