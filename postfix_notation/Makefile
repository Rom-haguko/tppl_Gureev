.PHONY: install run test coverage clean help

# Помощь: вывод доступных команд
help:
	@echo "Доступные команды:"
	@echo "  make install   - Установить зависимости (pytest, coverage)"
	@echo "  make run       - Запустить программу (пример: make run EXPR='3 0 4 ~ 2 ~')"
	@echo "  make test      - Запустить тесты"
	@echo "  make coverage  - Запустить тесты и показать процент покрытия"
	@echo "  make clean     - Очистить временные файлы и кэш"

# Установка зависимостей
install:
	pip install pytest pytest-cov

# Запуск программы (передавайте выражение через переменную EXPR)
run:
	@python main.py "$(EXPR)"

# Запуск тестов
test:
	pytest -v

# Запуск тестов с замером покрытия
coverage:
	pytest --cov=main --cov-report=term-missing --cov-report=html
	@echo "HTML-отчет сгенерирован в папке htmlcov/"

# Очистка мусора
clean:
	find . -type d -name "__pycache__" -exec rm -r {} +
	rm -rf .pytest_cache htmlcov .coverage