import ddddocr
filename = 'img/image4.jpg'
ocr = ddddocr.DdddOcr()
with open(filename,'rb') as fp:
    img_content = fp.read()
result = ocr.classification(img_content)
print(result)