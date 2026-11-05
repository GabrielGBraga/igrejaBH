import { Link } from "react-router-dom"

export function LandingAboutSection() {
  return (
    <section id="quem-somos" className="scroll-mt-20 py-16 sm:py-24 border-b border-border/40">
      <div className="mx-auto max-w-3xl px-4 sm:px-6 lg:px-8">
        {/* Title */}
        <div className="text-center mb-8 sm:mb-10">
          <h2 className="text-2xl sm:text-3xl md:text-4xl font-extrabold tracking-tight text-foreground">
            Quem somos
          </h2>
        </div>

        {/* Content Paragraphs matching design mockup */}
        <div className="space-y-6 text-sm sm:text-base leading-relaxed text-foreground/90 text-left sm:text-justify font-sans">
          <p>
            Somos um grupo de discípulos de Jesus, parte da Igreja do Senhor na Grande Belo Horizonte desde o início da década de 1990. Trata-se de uma comunidade não denominacional que, por revelação bíblica, decidiu não se organizar em grande templos e possuir placas e nomes. Afirmação de Pedro <em>&ldquo;O Deus que fez o mundo e tudo o que nele existe, sendo ele Senhor do céu e da terra, não habita em santuários feitos por mãos humanas.&rdquo;</em> (At 17.24) direciona a nossa fé a esse respeito. Cremos que a Igreja é composta por pessoas, e não prédios, e que a sua expressão prática é no dia a dia, de casa em casa, conforme o modelo vivido e deixado pelos Apóstolos.
          </p>

          <p>
            Usamos a expressão &ldquo;Igreja em BH&rdquo; para fazer referência a nossa existência enquanto instituição. Usamos essa expressão igualmente por revelação bíblica, compreendendo que era assim que a primeira igreja referia-se as comunidade locais que viviam em Unidade de Corpo. Contudo, não usamos essa expressão para se separar do resto da Igreja de Cristo que existe nesse cidade. Somos parte da Igreja que Jesus tem aqui na Grande Belo Horizonte.
          </p>
        </div>

        {/* Footer Link */}
        <div className="mt-8 sm:mt-10 text-center">
          <p className="text-sm sm:text-base text-foreground/90">
            Quer saber mais sobre a nossa história e o que cremos, clique{" "}
            <Link
              to="/quem-somos"
              className="underline underline-offset-4 font-medium hover:text-primary transition-colors focus-visible:outline-hidden focus-visible:ring-2 focus-visible:ring-primary rounded-xs"
            >
              aqui
            </Link>
            .
          </p>
        </div>
      </div>
    </section>
  )
}
