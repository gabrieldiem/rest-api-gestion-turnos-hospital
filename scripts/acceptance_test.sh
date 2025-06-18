#!/bin/bash

set -e

TARGET_URL=$1

RESET_URL="$TARGET_URL/reset"
PACIENTE_URL="$TARGET_URL/pacientes"
ESPECIALIDAD_URL="$TARGET_URL/especialidades"
MEDICO_URL="$TARGET_URL/medicos"
FECHA_URL="$TARGET_URL/fecha"
TURNO_URL="$TARGET_URL/medicos/NAC000/turnos-reservados"

echo "[SYSTEM] Inicializando entorno..."
RESET_STATUS=$(curl -X POST -s -o /dev/null -w "%{http_code}" "$RESET_URL")
if [ "$RESET_STATUS" -ne 200 ]; then
  echo "[FAIL] Reset fallo. Código de estado: $RESET_STATUS"
  exit 1
fi

FECHA_MOCK_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "$FECHA_URL" --header 'Content-Type: application/json' --data '{"fecha":"2025-06-19", "hora":"12:00"}')
if [ "$FECHA_MOCK_STATUS" -ne 200 ]; then
  echo "[FAIL] Mock de fecha fallo. Código de estado: $FECHA_MOCK_STATUS"
  exit 1
fi

echo "[SYSTEM] Inicializacion: OK"

echo "[SYSTEM] Registrando paciente..."
PACIENTE_RESP=$(curl -s -w "\n%{http_code}" --location "$PACIENTE_URL" --header 'Content-Type: application/json' --data '{"dni":"1234","username":"juanperez","email":"juano@mail.com"}')
PACIENTE_BODY=$(echo "$PACIENTE_RESP" | head -n -1)
PACIENTE_STATUS=$(echo "$PACIENTE_RESP" | tail -n1)

if [ "$PACIENTE_STATUS" -ne 201 ]; then
  echo "[FAIL] Error registrando paciente. Código: $PACIENTE_STATUS"
  exit 1
fi

echo "$PACIENTE_BODY" | grep -q '"username":"juanperez"' || { echo "[FAIL] Fallo en username del paciente"; exit 1; }
echo "$PACIENTE_BODY" | grep -q '"dni":"1234"' || { echo "[FAIL] Fallo en dni del paciente"; exit 1; }
echo "$PACIENTE_BODY" | grep -q '"email":"juano@mail.com"' || { echo "[FAIL] Fallo en email del paciente"; exit 1; }
echo "[ACCEPTANCE_TEST] Paciente: OK"

echo "[SYSTEM] Creando especialidad..."
ESPECIALIDAD_RESP=$(curl -s -w "\n%{http_code}" --location "$ESPECIALIDAD_URL" --header 'Content-Type: application/json' --data '{"nombre":"Pediatria","duracion":60,"recurrencia_maxima":20,"codigo":"pedi"}')
ESPECIALIDAD_BODY=$(echo "$ESPECIALIDAD_RESP" | head -n -1)
ESPECIALIDAD_STATUS=$(echo "$ESPECIALIDAD_RESP" | tail -n1)

if [ "$ESPECIALIDAD_STATUS" -ne 201 ]; then
  echo "[FAIL] Error creando especialidad. Código: $ESPECIALIDAD_STATUS"
  exit 1
fi

echo "$ESPECIALIDAD_BODY" | grep -q '"nombre":"Pediatria"' || { echo "[FAIL] Fallo en nombre de especialidad"; exit 1; }
echo "$ESPECIALIDAD_BODY" | grep -q '"duracion":60' || { echo "[FAIL] Fallo en duracion de especialidad"; exit 1; }
echo "$ESPECIALIDAD_BODY" | grep -q '"recurrencia_maxima":20' || { echo "[FAIL] Fallo en recurrencia_maxima"; exit 1; }
echo "$ESPECIALIDAD_BODY" | grep -q '"codigo":"pedi"' || { echo "[FAIL] Fallo en codigo de especialidad"; exit 1; }
echo "[ACCEPTANCE_TEST] Especialidad: OK"

echo "[SYSTEM] Creando medico..."
MEDICO_RESP=$(curl -s -w "\n%{http_code}" --location "$MEDICO_URL" --header 'Content-Type: application/json' --data '{"nombre":"Jorge","apellido":"Ponzi","matricula":"NAC000","especialidad":"pedi"}')
MEDICO_BODY=$(echo "$MEDICO_RESP" | head -n -1)
MEDICO_STATUS=$(echo "$MEDICO_RESP" | tail -n1)

if [ "$MEDICO_STATUS" -ne 201 ]; then
  echo "[FAIL] Error creando medico. Código: $MEDICO_STATUS"
  exit 1
fi

echo "$MEDICO_BODY" | grep -q '"nombre":"Jorge"' || { echo "[FAIL] Fallo en nombre de medico"; exit 1; }
echo "$MEDICO_BODY" | grep -q '"apellido":"Ponzi"' || { echo "[FAIL] Fallo en apellido de medico"; exit 1; }
echo "$MEDICO_BODY" | grep -q '"matricula":"NAC000"' || { echo "[FAIL] Fallo en matricula de medico"; exit 1; }
echo "$MEDICO_BODY" | grep -q '"especialidad":"pedi"' || { echo "[FAIL] Fallo en especialidad de medico"; exit 1; }
echo "[ACCEPTANCE_TEST] Medico: OK"

echo "[SYSTEM] Reservando turno..."
TURNO_RESP=$(curl -s -w "\n%{http_code}" --location "$TURNO_URL" --header 'Content-Type: application/json' --data '{"dni":"1234","turno":{"fecha":"2025-06-19","hora":"12:00"}}')
TURNO_BODY=$(echo "$TURNO_RESP" | head -n -1)
TURNO_STATUS=$(echo "$TURNO_RESP" | tail -n1)

if [ "$TURNO_STATUS" -ne 201 ]; then
  echo "[FAIL] Error reservando turno. Código: $TURNO_STATUS"
  exit 1
fi

echo "$TURNO_BODY" | grep -q '"matricula":"NAC000"' || { echo "[FAIL] Fallo en matricula de turno"; exit 1; }
echo "$TURNO_BODY" | grep -q '"dni":"1234"' || { echo "[FAIL] Fallo en dni de turno"; exit 1; }
echo "$TURNO_BODY" | grep -q '"fecha":"2025-06-19"' || { echo "[FAIL] Fallo en fecha de turno"; exit 1; }
echo "$TURNO_BODY" | grep -q '"hora":"12:00"' || { echo "[FAIL] Fallo en hora de turno"; exit 1; }
echo "[ACCEPTANCE_TEST] Turno: OK"

echo "[ACCEPTANCE_TEST] Test completo: OK"

echo "[SYSTEM] Reseteando entorno..."
FECHA_MOCK_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "$FECHA_URL" --header 'Content-Type: application/json' --data '{"fecha":"2025-06-19", "hora":"12:00"}')
if [ "$FECHA_MOCK_STATUS" -ne 200 ]; then
  echo "[FAIL] Reset fallo. Código de estado: $FECHA_MOCK_STATUS"
  exit 1
fi

RESET_FECHA_STATUS=$(curl -X DELETE -s -o /dev/null -w "%{http_code}" "$FECHA_URL")
if [ "$RESET_FECHA_STATUS" -ne 200 ]; then
  echo "[FAIL] Reset fallo. Código de estado: $RESET_FECHA_STATUS"
  exit 1
fi

echo "[SYSTEM] Reset: OK"

exit 0
