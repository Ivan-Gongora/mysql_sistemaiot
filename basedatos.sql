-- -----------------------------------------------------------
-- CREACIÓN COMPLETA DE LA BASE DE DATOS sistema_iotA_db
-- -----------------------------------------------------------

-- Paso 1: Configuración inicial
CREATE DATABASE IF NOT EXISTS sistemaiotA_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE sistemaiotA_db;

-- -----------------------------------------------------------
-- Paso 2: Tablas principales (Usuarios y Proyectos)
-- -----------------------------------------------------------

CREATE TABLE usuarios (
  id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  nombre_usuario VARCHAR(150) NOT NULL UNIQUE,
  nombre VARCHAR(30) NOT NULL,
  apellido VARCHAR(30) NOT NULL,
  email VARCHAR(254) NOT NULL,
  contrasena VARCHAR(128) NOT NULL,
  activo BOOLEAN NOT NULL DEFAULT TRUE,
  fecha_registro DATETIME NOT NULL,
  ultimo_login DATETIME
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE proyectos (
  id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(80) NOT NULL,
  descripcion TEXT NOT NULL,
  tipo_industria VARCHAR(50) NOT NULL DEFAULT 'General',
  usuario_id INT NOT NULL,
  FOREIGN KEY (usuario_id) REFERENCES usuarios(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- -----------------------------------------------------------
-- Paso 3: Tablas de configuración
-- -----------------------------------------------------------

CREATE TABLE unidades_medida (
  id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(20) NOT NULL,
  simbolo VARCHAR(10) NOT NULL,
  descripcion VARCHAR(100),
  magnitud_tipo VARCHAR(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- -----------------------------------------------------------
-- Paso 4: Tablas de hardware
-- -----------------------------------------------------------

CREATE TABLE dispositivos (
  id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(80) NOT NULL,
  descripcion TEXT NOT NULL,
  tipo VARCHAR(40) NOT NULL,
  latitud DOUBLE,
  longitud DOUBLE,
  habilitado BOOLEAN NOT NULL,
  fecha_creacion DATETIME NOT NULL,
  proyecto_id INT NOT NULL,
  FOREIGN KEY (proyecto_id) REFERENCES proyectos(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE sensores (
  id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(40) NOT NULL,
  tipo VARCHAR(40) NOT NULL,
  fecha_creacion DATETIME NOT NULL,
  habilitado BOOLEAN NOT NULL,
  dispositivo_id INT NOT NULL,
  FOREIGN KEY (dispositivo_id) REFERENCES dispositivos(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE campos_sensores (
  id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(30) NOT NULL,
  tipo_valor VARCHAR(40) NOT NULL,
  sensor_id INT NOT NULL,
  unidad_medida_id INT,
  FOREIGN KEY (sensor_id) REFERENCES sensores(id),
  FOREIGN KEY (unidad_medida_id) REFERENCES unidades_medida(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- -----------------------------------------------------------
-- Paso 5: Tabla de registro de valores
-- -----------------------------------------------------------

CREATE TABLE valores (
  id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  valor DECIMAL(15,6) NOT NULL,
  fecha_hora_lectura DATETIME NOT NULL,
  fecha_hora_registro DATETIME NULL,
  campo_id INT NOT NULL,
  FOREIGN KEY (campo_id) REFERENCES campos_sensores(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE ultimo_valor_campo (
    campo_id INT NOT NULL PRIMARY KEY,
    ultimo_valor DECIMAL(15,6) NULL,
    fecha DATETIME NULL,
    FOREIGN KEY (campo_id) REFERENCES campos_sensores(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- -----------------------------------------------------------
-- TRIGGER: set_fecha_registro_valores
-- -----------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS set_fecha_registro_valores$$
CREATE TRIGGER set_fecha_registro_valores
BEFORE INSERT ON valores
FOR EACH ROW
BEGIN
    IF NEW.fecha_hora_registro IS NULL THEN
        SET NEW.fecha_hora_registro = NOW();
    END IF;
END$$
DELIMITER ;


DELIMITER $$

DROP TRIGGER IF EXISTS tg_valores_after_insert$$

CREATE TRIGGER tg_valores_after_insert
AFTER INSERT ON valores
FOR EACH ROW
BEGIN
    INSERT INTO ultimo_valor_campo (campo_id, ultimo_valor, fecha)
    VALUES (NEW.campo_id, NEW.valor, NEW.fecha_hora_lectura)
    ON DUPLICATE KEY UPDATE 
        ultimo_valor = NEW.valor,
        fecha = NEW.fecha_hora_lectura;
END$$

DELIMITER ;

-- -----------------------------------------------------------
-- Paso 6: Roles y permisos
-- -----------------------------------------------------------

CREATE TABLE roles (
    id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    nombre_rol VARCHAR(50) NOT NULL UNIQUE,
    descripcion TEXT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE proyecto_usuarios (
    id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    proyecto_id INT NOT NULL,
    usuario_id INT NOT NULL,
    rol_id INT NOT NULL,
    UNIQUE (proyecto_id, usuario_id),
    FOREIGN KEY (proyecto_id) REFERENCES proyectos(id),
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id),
    FOREIGN KEY (rol_id) REFERENCES roles(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE permisos (
    id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    nombre_permiso VARCHAR(80) NOT NULL UNIQUE,
    descripcion TEXT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE rol_permisos (
    rol_id INT NOT NULL,
    permiso_id INT NOT NULL,
    PRIMARY KEY (rol_id, permiso_id),
    FOREIGN KEY (rol_id) REFERENCES roles(id),
    FOREIGN KEY (permiso_id) REFERENCES permisos(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- -----------------------------------------------------------
-- Paso 7: Recibos de energía
-- -----------------------------------------------------------

CREATE TABLE recibos_energia (
    id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    usuario_id INT NOT NULL,
    periodo DATE NOT NULL,
    fecha_carga DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    consumo_total_kwh DECIMAL(10,2) NOT NULL,
    demanda_maxima_kw DECIMAL(10,2) NOT NULL,
    costo_total DECIMAL(10,2) NOT NULL,
    dias_facturados INT NOT NULL,
    factor_potencia DECIMAL(5,2) NULL,
    tarifa VARCHAR(50) NULL,
    kwh_punta DECIMAL(10,2) NULL,
    lote_nombre VARCHAR(255) NOT NULL DEFAULT 'default',
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE,
    UNIQUE (usuario_id, lote_nombre, periodo)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- -----------------------------------------------------------
-- Paso 8: Tabla de valores agregados
-- -----------------------------------------------------------

CREATE TABLE valores_agregados (
  id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  campo_id INT NOT NULL,
  fecha DATE NOT NULL,
  hora TINYINT NOT NULL,
  valor_sum DECIMAL(15,6) NULL,
  valor_min DECIMAL(15,6),
  valor_max DECIMAL(15,6),
  valor_avg DECIMAL(15,6),
  total_registros INT,
  UNIQUE KEY uk_campo_fecha_hora (campo_id, fecha, hora),
  INDEX idx_fecha_campo (fecha, campo_id),
  FOREIGN KEY (campo_id) REFERENCES campos_sensores(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- -----------------------------------------------------------
-- Paso 9: Logs del sistema
-- -----------------------------------------------------------

CREATE TABLE sistema_logs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    mensaje TEXT NOT NULL,
    tipo ENUM('info','warning','error') DEFAULT 'info',
    fecha DATETIME DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_fecha (fecha),
    INDEX idx_tipo (tipo)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- -----------------------------------------------------------
-- Paso 10: Índices críticos
-- -----------------------------------------------------------

CREATE INDEX idx_valores_campo_fecha ON valores(campo_id, fecha_hora_lectura);
CREATE INDEX idx_valores_fecha_campo ON valores(fecha_hora_lectura, campo_id);
CREATE INDEX idx_valores_fecha ON valores(fecha_hora_lectura);
CREATE INDEX idx_valores_campo ON valores(campo_id);
CREATE INDEX idx_proyectos_usuario ON proyectos(usuario_id);
CREATE INDEX idx_dispositivos_proyecto ON dispositivos(proyecto_id);
CREATE INDEX idx_sensores_dispositivo ON sensores(dispositivo_id);

-- -----------------------------------------------------------
-- Paso 11: Activar eventos
-- -----------------------------------------------------------

SET GLOBAL event_scheduler = ON;

DELIMITER $$

CREATE EVENT ev_agregacion_inteligente
ON SCHEDULE EVERY 1 HOUR
STARTS CURRENT_TIMESTAMP
DO
BEGIN
    DECLARE v_datos_pendientes INT DEFAULT 0;
    DECLARE v_ultima_agregacion DATETIME;
    DECLARE v_filas_agregadas INT DEFAULT 0;

    SELECT COUNT(*) INTO v_datos_pendientes
    FROM valores v
    WHERE NOT EXISTS (
        SELECT 1
        FROM valores_agregados va
        WHERE va.campo_id = v.campo_id
          AND va.fecha = DATE(v.fecha_hora_lectura)
          AND va.hora = HOUR(v.fecha_hora_lectura)
    )
    AND v.fecha_hora_lectura >= NOW() - INTERVAL 7 DAY;

    SELECT MAX(fecha) INTO v_ultima_agregacion
    FROM sistema_logs
    WHERE mensaje LIKE '%Agregación completada%'
      AND fecha >= NOW() - INTERVAL 2 HOUR;

    IF v_datos_pendientes > 0 OR v_ultima_agregacion IS NULL THEN
        INSERT INTO sistema_logs (mensaje, tipo)
        VALUES (
            CONCAT('AGREGACIÓN INTELIGENTE: ', v_datos_pendientes, ' registros pendientes.'),
            'info'
        );

        INSERT INTO valores_agregados (
            campo_id, fecha, hora, valor_min, valor_max, valor_avg, valor_sum, total_registros
        )
        SELECT
            v.campo_id,
            DATE(v.fecha_hora_lectura),
            HOUR(v.fecha_hora_lectura),
            MIN(v.valor),
            MAX(v.valor),
            CASE WHEN cs.nombre = 'Movimiento' THEN NULL ELSE AVG(v.valor) END,
            CASE WHEN cs.nombre = 'Movimiento' THEN SUM(v.valor) ELSE NULL END,
            COUNT(*)
        FROM valores v
        JOIN campos_sensores cs ON v.campo_id = cs.id
        WHERE NOT EXISTS (
            SELECT 1 FROM valores_agregados va
            WHERE va.campo_id = v.campo_id
              AND va.fecha = DATE(v.fecha_hora_lectura)
              AND va.hora = HOUR(v.fecha_hora_lectura)
        )
        GROUP BY v.campo_id, cs.nombre, fecha, hora;

        SET v_filas_agregadas = ROW_COUNT();

        INSERT INTO sistema_logs (mensaje, tipo)
        VALUES (
            CONCAT('BACKUP: agregación automática completada. Filas agregadas: ', v_filas_agregadas),
            'info'
        );
    END IF;
END$$

DELIMITER ;

DELIMITER $$

CREATE EVENT ev_mantenimiento_inteligente
ON SCHEDULE EVERY 1 DAY
STARTS CURRENT_TIMESTAMP + INTERVAL 1 DAY
DO
BEGIN
    DECLARE v_registros_problematicos INT DEFAULT 0;

    SELECT COUNT(DISTINCT CONCAT(campo_id, '_', DATE(fecha_hora_lectura), '_', HOUR(fecha_hora_lectura)))
    INTO v_registros_problematicos
    FROM valores v
    WHERE NOT EXISTS (
        SELECT 1 FROM valores_agregados va 
        WHERE va.campo_id = v.campo_id 
          AND va.fecha = DATE(v.fecha_hora_lectura)
          AND va.hora = HOUR(v.fecha_hora_lectura)
    )
    AND v.fecha_hora_lectura >= NOW() - INTERVAL 30 DAY;

    IF v_registros_problematicos > 0 THEN
        INSERT INTO sistema_logs (mensaje, tipo)
        VALUES (CONCAT('MANTENIMIENTO: ', v_registros_problematicos, ' registros problemáticos detectados'), 'warning');
    ELSE
        INSERT INTO sistema_logs (mensaje, tipo)
        VALUES ('MANTENIMIENTO: No se detectaron registros problemáticos', 'info');
    END IF;
END$$

DELIMITER ;
