from flask import Flask, request, send_file
import os
import random
from datetime import datetime

app = Flask(__name__)

@app.route('/predictions/garbage_cont_classify', methods=['POST'])
def classify_garbage_cont():
    # Получаем переданное изображение
    image = request.files['data']
    
    # Генерируем имя файла на основе текущей даты и времени
    current_datetime = datetime.now().strftime("%Y-%m-%dT%H-%M-%S")
    image_filename = f"image_{current_datetime}"
    
    # Определяем расширение файла изображения
    image_extension = image.filename.rsplit('.', 1)[1].lower()
    
    # Проверяем допустимые расширения файлов
    if image_extension not in ['jpg', 'png']:
        return jsonify({'error': 'Недопустимое расширение файла. Разрешены только .jpg и .png.'})
    
    # Сохраняем изображение на сервере
    image.save(f'request-images/{image_filename}.{image_extension}')
    

    # Получаем список текстовых файлов в специальной папке
    doc_folder = 'response-docs'
    doc_files = [f for f in os.listdir(doc_folder) if f.endswith('.txt')]
    
    # Выбираем случайный текстовый файл
    random_doc = random.choice(doc_files)
    
    # Отправляем файл в виде ответа
    return send_file(os.path.join(doc_folder, random_doc), mimetype='text/plain')


if __name__ == '__main__':
    app.run(host="0.0.0.0", port=8080)
