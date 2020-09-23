defmodule DevopsSkillsMatrix.MixProject do
  use Mix.Project

  def project do
    [
      app: :devops_skills_matrix,
      version: "0.1.0",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
      # [applications: [:xlsxir]]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:xlsxir, "~> 1.6.4"}
    ]
  end
end
