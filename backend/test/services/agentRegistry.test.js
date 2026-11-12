import { jest, describe, it, expect } from '@jest/globals';

// O seam é o REGISTRY exportado: lemos os basePrompt puros, sem tocar banco.
// Mocks so isolam as dependencias de import do registro (que nao sao exercitadas
// aqui).
jest.unstable_mockModule('../../src/config/database.js', () => ({
  getDatabase: jest.fn(),
}));
jest.unstable_mockModule('../../src/services/userProfilePromptService.js', () => ({
  default: {},
}));

const { REGISTRY } = await import('../../src/agents/agentRegistry.js');

describe('agentRegistry — transparência na saudação', () => {
  it('expõe os três agentes', () => {
    expect(Object.keys(REGISTRY).sort()).toEqual(['luna', 'otto', 'tina']);
  });

  it('instrui todos os agentes a se apresentar e deixar claro o que acessam', () => {
    for (const agent of [REGISTRY.luna, REGISTRY.otto, REGISTRY.tina]) {
      expect(agent.basePrompt).toContain('Na sua primeira mensagem, apresente-se');
      expect(agent.basePrompt).toContain('deixe claro');
      expect(agent.basePrompt).toContain('assistente ideal');
    }
  });

  it('Luna lista contas/saldo, receitas e despesas — e nada de despensa ou diário', () => {
    const p = REGISTRY.luna.basePrompt;
    expect(p).toContain('contas e saldos');
    expect(p).toContain('receitas');
    expect(p).toContain('despesas');
    expect(p).not.toContain('despensa');
    expect(p).not.toContain('diário');
  });

  it('Otto lista a despensa de cozinha e os gastos com alimentação', () => {
    const p = REGISTRY.otto.basePrompt;
    expect(p).toContain('despensa de cozinha');
    expect(p).toContain('gastos recentes com alimentação');
    expect(p).not.toContain('contas e saldos');
    expect(p).not.toContain('diário');
  });

  it('Tina lista a despensa de produtos domésticos e o diário', () => {
    const p = REGISTRY.tina.basePrompt;
    expect(p).toContain('despensa de produtos domésticos');
    expect(p).toContain('diário');
    expect(p).not.toContain('contas e saldos');
  });
});
