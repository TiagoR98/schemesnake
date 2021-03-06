;bibliotecas necessarias
(require (lib "tabuleiro.scm" "user-feup"))
(require (lib "audio.scm" "user-feup"))
(require (lib "swgr.scm" "user-feup"))
(require (lib "graphics.ss" "graphics"))

;abre a janela inicial
(open-graphics)

(define janela-ini (open-viewport "🐍  Scheme λ Snake  🐍" 1190 720))
;desenha a imagem inicial na tela
(((draw-pixmap-posn "titulo.bmp" 'bmp) janela-ini) (make-posn 0 0) #f)

;tempo de espera até fechar a janela
(sleep 6)

;fecha a janela inicial
(close-graphics)

;janela do jogo
(janela 1190 720 "🐍  Scheme λ Snake  🐍")
(define tabjogo (tabuleiro 10 690 30 39 22))

;variavel que determina se o jogo fica invertido
(define inverte #f)

;cria posicao inicial cobra
(define init-snake (list (cons 0 2) (cons 1 2) (cons 1 3) (cons 1 4) (cons 1 5) (cons 2 5)))

;lista dos tipos de objetos disponiveis
(define tipo-objeto (list (cons 'p 3) (cons'n 18) (cons's 2) (cons 'x 20)))
;objeto atual no jogo
(define indice-item-atual 0)

;lista de velocidades (normal,rapido,lento) - usadas na funcao sleep
(define velocidade (list 0.05 0.03 0.08))
;velocaidade atual da serpente
(define velocidade-atual (list-ref velocidade 0))

;criação de um novo objeto
(define novo-objeto
  (lambda (snake primeiro)
    ;gera duas coordenadas aleatórias para o objeto
    (let ((coord (cons (random (cel-x tabjogo)) (random (cel-y tabjogo)))))
    
     ;se a posição do novo objeto coincidir com a serpente, gera novas coordenadas
     (if (member coord snake)
         (novo-objeto snake #f)
         
         ;gera um aleatorio de 0 100 de modo a definir as probabilidades dos objetos
         (let ((item-atual (random 100)))
           
           ;analisa o objeto comido anteriormente e ajusta a jogabilidade de acordo com o seu tipo
           (cond 
             ((= indice-item-atual 0) (set! velocidade-atual (list-ref velocidade 0)) (set! inverte #f))
             ((= indice-item-atual 1) (set! velocidade-atual (list-ref velocidade 1)) (set! inverte #f))
             ((= indice-item-atual 2) (set! velocidade-atual (list-ref velocidade 2)) (set! inverte #f))
             ((= indice-item-atual 3) (set! velocidade-atual (list-ref velocidade 0)) (set! inverte #t)))
           
           ;define o objeto atual a ser desenhado no tabuleiro
           ;cada objeto tem uma determinada probabilidade de aparecer de acordo com o valor gerado anteriormente (0%-100%)
           (cond 
             ;se o objeto for o primeiro do jogo, entao ignora-se o valor gerado e são establecidas as regras iniciais
             ((or (<= item-atual 60) primeiro) (set! indice-item-atual 0))
             ((and (<= item-atual 70) (> item-atual 60)) (set! indice-item-atual 3))
             ((and (<= item-atual 85) (> item-atual 70)) (set! indice-item-atual 1))
             ((and (<= item-atual 100) (> item-atual 85)) (set! indice-item-atual 2)))
           
           
    ;cria o objeto na célua indicada (símbolo e fundo)
    (celula tabjogo (car coord) (cdr coord) 'l (cdr (list-ref tipo-objeto indice-item-atual)))
    (celula tabjogo (car coord) (cdr coord) (car (list-ref tipo-objeto indice-item-atual)) 26)
         
           
      coord)))))

(define objeto (novo-objeto init-snake #t))

;inicializa as variaveis relativas a pontuacao mais alta
(define pontalta 0)
(define pont 0)
(define pontalta-pos (list 1120 10))
(define pont-pos (list 870 10))

;desenha legenda
(define init-legenda
 (lambda ()
   
   (move (list 10 698))
   (cor 0)
   (desenha-txt "🐍  Scheme λ Snake  🐍")
   (move (list 350 698))
   (desenha-txt "Fundamentos da Programação  FEUP  2017 ")                                   
   (move (list 900 698))
   (desenha-txt "Programado por Tiago Ribeiro")
   
   (move (list 10 10))
   (desenha-txt "Legenda:  ")
   
   (cor 3)
   (desenha-txt (symbol->string '●))
   (cor 0)
   (desenha-txt " - Item Normal    ")
   
   (cor 18)
   (desenha-txt (symbol->string '↑))
   (cor 0)
   (desenha-txt " - Item Rápido    ")
   
   (cor 2)
   (desenha-txt (symbol->string '↓))
   (cor 0)
   (desenha-txt " - Item Lento     ")
   
   (cor 20)
   (desenha-txt (symbol->string 'X))
   (cor 0)
   (desenha-txt " - Item Invertido   ")
   
   (move (list (-(car pont-pos) 100) (cadr pont-pos)))
   (desenha-txt "Pontuação:")
   (move (list (-(car pontalta-pos) 170) (cadr pont-pos)))
   (desenha-txt "Pontuação Máxima:")))

;carrega a pontuacao mais alta
(define load-pontalta 
  (lambda ()
    
         (if (not(file-exists? "schemesnake_score.txt"))
             ;se nao exitir ficheiro de pontuacao alta e criado um novo com o valor 0
         (letrec ((novo-ficheiro (open-output-file "schemesnake_score.txt")))
           (display 0 novo-ficheiro)
           (close-output-port novo-ficheiro)))
    ;carregar o valor do ficheiro para a pontuacao alta atual
    (set! pontalta (read(open-input-file "schemesnake_score.txt")))
    (move pontalta-pos)
    (cor 0)
   (desenha-txt (number->string  pontalta))))     



;desenha high-score
(define atualiza-pontuacao
 (lambda (pontos)
   ;limpa o valor anterior
   (move pont-pos)
   (cor 26)
   (desenha-txt (number->string  pont))
   
   ;desenha o novo valor
   (move pont-pos)
   (cor 0)
   (set! pont (+ pont pontos))
   (desenha-txt (number->string  pont))
   ;se a pontucao atual bater a high-score previamente guardada, o valor desta e atualizado no ecra
   (if (> pont pontalta)
       (begin
         (move pontalta-pos)
         (cor 26)
         (desenha-txt (number->string (- pont pontos)))
         
         (move pontalta-pos)
         (cor 0)
         (desenha-txt (number->string  pont))))))

;procedimento de inicio do jogo
(define jogo
  (lambda (snake)
    ;incialização da cobra
    (celulas tabjogo snake 'l 0 0)
    
    (load-pontalta)    
    (init-legenda)
    (atualiza-pontuacao 0)
    
    ;musica de abertura
    (som "la")
    (sleep 0.05)
    (som "do")
    (sleep 0.05)
    (som "re")
    (sleep 0.5)
    (som "la")
    (sleep 0.05)
    (som "do")
    (sleep 0.05)
    (som "mi")
    (som "re")
    (sleep 0.4)
    (som "la")
    (sleep 0.05)
    (som "do")
    (sleep 0.05)
    (som "re")
    (sleep 0.1)
    (som "do")
    (sleep 0.05)
    (som "la")

    
    (letrec ((snake init-snake)
             (direcao 'right)
             ;procedimento auxiliar responsável por ler o teclado e atualizar recusivamente o jogo
             (principal
              (lambda (snake)
                
                  
                ;intervalo de tempo para controlar a velocidade do jogo
                (sleep velocidade-atual)
                ;deteção da tecla pressionada no momento
                (let ((temp #t)
                      (tecla (tecla-pressionada #f)))
                  
                ;mudança de direção apenas se for pressionada uma tecla
                (if (not (void? tecla))
                    (begin
                      
                    ;se o jogo estiver invertido, a tecla pressionada pelo utilizodor será alterada para a oposta
                    (if inverte
                        (cond
                                    ((eq? tecla 'right) (set! tecla 'left))
                                    ((eq? tecla 'left) (set! tecla 'right))
                                    ((eq? tecla 'up) (set! tecla 'down))
                                    ((eq? tecla 'down) (set! tecla 'up))))
                    
                     ;impede que o jogador vire a cobra contra si mesma (180 graus)
                    (if (not(or (and (eq? direcao 'right) (eq? tecla 'left))
                            (and (eq? direcao 'left) (eq? tecla 'right))
                            (and (eq? direcao 'up) (eq? tecla 'down))
                            (and (eq? direcao 'down) (eq? tecla 'up))))
                            
                              
                    (set! direcao tecla))))
                  
                  
                  ;chamada pelo procedimento que calcula a nova cobra após um novo instante do jogo
                  (set! temp (snake-move snake direcao))
                  (if (not (eq? temp #f)) (set! snake temp)) 
                  
                  ;termina o jogo em caso de derrota
                  (if (not(eq? temp #f))    
                  ;repete o ciclo principal do jogo
                  (principal snake)
                  
                  ;termina o jogo
                  (begin
                   ;se a pontuacao alta for superior a anterior, gurada-a no ficheiro
                  (if (> pont pontalta)
                      (letrec ((guarda-pontalta (open-output-file "schemesnake_score.txt" 'replace)))
                  (display pont guarda-pontalta)
                  (close-output-port guarda-pontalta)))
                  (sleep 1)
                  (fecha-janela)))))))
      
             (principal snake))))
             
             



(define snake-move
  (lambda (snake direcao)  
    
    (let* (;eliminação do último pixel na nova cobra
           (snake-next (list-tail snake 1))
           ;obtenção das coordenadas do primeiro pixel da cobra (atual)
             (x (car (list-ref snake-next (sub1 (length snake-next)))))
             (y (cdr (list-ref snake-next (sub1 (length snake-next))))))
          
       ;cálculo do primeiro pixel da nova cobra de acordo com a direção do jogo 
      (cond
        ((eq? direcao 'right) (set! x (add1 x)))
        ((eq? direcao 'left) (set! x (sub1 x)))
        ((eq? direcao 'up) (set! y (sub1 y)))
        ((eq? direcao 'down) (set! y (add1 y))))
      
      ;se a cobra colidir com algum dos limites do tabuleiro, reaparece no limite oposto
      (cond ((= x (cel-x tabjogo)) (set! x 0))
            ((< x 0) (set! x (sub1 (cel-x tabjogo))))
            ((= y (cel-y tabjogo)) (set! y 0))
            ((< y 0) (set! y (sub1 (cel-y tabjogo)))))
      
      ;para o jogo se a cobra tiver batido em si mesmo
      (if (member (cons x y) snake)
          ;escreve mensagem fim de jogo
          (begin
            ;pinta a cobra de vermelho
            (celulas tabjogo (reverse snake) 'l 20 18)
            ;som fim de jogo
            (som "bomba1")
            #f)
          
          (begin
            
      ;adição do novo pixel à lista da cobra
      (append! snake-next (list (cons x y)))
     
            
      ;atualização dos pixeis em questão (primeiro e último)
      (celula tabjogo x y 'l 0)
      ;se a serpente apanhar o objeto, gera um novo
      (if (and (eq? (car objeto) x) (eq? (cdr objeto) y))
          (begin
            ;cancela a eliminação do ultimo pixel, aumentando o tamanho da cobra
            (set! snake-next (append (list (car snake)) snake-next))
            (set! objeto (novo-objeto snake-next #f))
            (atualiza-pontuacao 1)) 
          ;elimina o ultimo pixel da serpente
          (celula tabjogo (caar snake) (cdr (car snake)) 'l 26))
      
      ;retorno da nova lista da cobra
      snake-next)))))

(jogo init-snake)
;abre a janela de game over
(open-graphics)

(define janela-ini (open-viewport "🐍  Scheme λ Snake  🐍" 1190 720))
;desenha a imagem na tela
(((draw-pixmap-posn "gameover.bmp" 'bmp) janela-ini) (make-posn 0 0) #f)

;tempo de espera até fechar a janela
(sleep 6)

;fecha a janela de game over
(close-graphics)